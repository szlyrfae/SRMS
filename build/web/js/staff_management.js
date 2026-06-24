/**
 * Staff Management JavaScript Pipeline
 */

// Mod kawalan penunjuk status operasi borang (add atau update)
let currentAction = 'add';

document.addEventListener('DOMContentLoaded', function() {
    initNavigation();
    initModal();
    initFormSubmit();
    loadStaffFromDatabase();
});

function initNavigation() {
    const navDashboard = document.getElementById('navDashboard');
    const navHall = document.getElementById('navHall');
    const navStaff = document.getElementById('navStaff');
    const navReport = document.getElementById('navReport');
    const navReservation = document.getElementById('navReservation');
    
    if (navDashboard) navDashboard.onclick = () => window.location.href = 'staff_dashboard.jsp';
    if (navHall) navHall.onclick = () => window.location.href = 'hall.jsp';
    if (navStaff) navStaff.onclick = () => window.location.href = 'staff.jsp';
    if (navReport) navReport.onclick = () => window.location.href = 'ReportServlet';
    if (navReservation) navReservation.onclick = () => window.location.href = 'EventListServlet';
}

function loadStaffFromDatabase() {
    fetch('staff_ajax.jsp?action=getAll')
        .then(response => response.text())
        .then(text => {
            try {
                const data = JSON.parse(text);
                if (data.success) {
                    updateTable(data.staff);
                } else {
                    showToast('Failed to sync staff list', 'error');
                }
            } catch (e) {
                console.error('Parse error:', e, text);
                showToast('Format mismatch reading users', 'error');
            }
        })
        .catch(error => {
            console.error('Fetch error:', error);
            showToast('Network interface blocked', 'error');
        });
}

function showToast(message, type = 'success') {
    const toast = document.createElement('div');
    toast.className = `error-toast ${type === 'success' ? 'success-toast' : ''}`;
    toast.innerHTML = `<i class="fas ${type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle'}"></i> ${message}`;
    
    const bgColor = type === 'success' ? '#2e7d32' : '#c62828';
    toast.style.cssText = `
        position: fixed;
        bottom: 20px;
        right: 20px;
        background: ${bgColor};
        color: white;
        padding: 12px 20px;
        border-radius: 8px;
        z-index: 2000;
        animation: fadeInOut 3s ease;
    `;
    document.body.appendChild(toast);
    setTimeout(() => toast.remove(), 3000);
}

function updateTable(staffList) {
    const tbody = document.getElementById('staffTableBody');
    if (!tbody) return;
    
    if (!staffList || staffList.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; color:#888;">No staff records found.</td></tr>';
        return;
    }
    
    tbody.innerHTML = '';
    staffList.forEach(staff => {
        const row = tbody.insertRow();
        row.setAttribute('data-id', staff.id);
        
        row.insertCell(0).textContent = staff.id;
        row.insertCell(1).textContent = staff.name;
        
        const roleCell = row.insertCell(2);
        roleCell.innerHTML = `<span class="status-badge staff">${staff.role}</span>`;
        
        const actionsCell = row.insertCell(3);
        actionsCell.className = 'actions';
        actionsCell.innerHTML = `
            <button class="edit-btn" onclick="editStaff(this)"><i class="fas fa-edit"></i> Edit</button>
            <button class="delete-btn" onclick="deleteStaff('${staff.id}')"><i class="fas fa-trash-alt"></i> Delete</button>
        `;
    });
}

function initModal() {
    const modal = document.getElementById('staffModal');
    const addBtn = document.getElementById('addStaffBtn');
    const closeBtn = document.getElementById('closeModalBtn') || document.querySelector('.close-modal');
    
    if (addBtn) {
        addBtn.onclick = () => {
            currentAction = 'add'; // Set status operasi "ADD"
            document.getElementById('modalTitle').innerHTML = '<i class="fas fa-plus-circle"></i> Add New Staff';
            document.getElementById('staffForm').reset();
            document.getElementById('staffId').disabled = false; // Buka input ID untuk diisi manual
            modal.style.display = 'block';
        };
    }
    
    if (closeBtn) closeBtn.onclick = () => modal.style.display = 'none';
    
    window.onclick = (event) => {
        if (event.target === modal) modal.style.display = 'none';
    };
}

function initFormSubmit() {
    const form = document.getElementById('staffForm');
    if (form) {
        form.onsubmit = (e) => {
            e.preventDefault();
            saveStaff();
        };
    }
}

function saveStaff() {
    const staffId = document.getElementById('staffId').value.trim();
    const staffName = document.getElementById('staffName').value.trim();
    const staffPassword = document.getElementById('staffPassword').value.trim();
    const staffRole = document.getElementById('staffRole').value;
    
    if (!staffId || !staffName || !staffPassword) {
        showToast('All fields are mandatory', 'error');
        return;
    }
    
    const params = new URLSearchParams();
    params.append('action', currentAction); // Menghantar sama ada 'add' atau 'update'
    params.append('id', staffId);
    params.append('name', staffName);
    params.append('password', staffPassword);
    params.append('role', staffRole);
    
    fetch('staff_ajax.jsp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params
    })
    .then(response => response.text())
    .then(text => {
        try {
            const data = JSON.parse(text);
            if (data.success) {
                document.getElementById('staffModal').style.display = 'none';
                loadStaffFromDatabase();
                showToast(currentAction === 'update' ? 'Staff updated successfully!' : 'New staff added successfully!');
            } else {
                showToast('Transaction rejected: ' + data.message, 'error');
            }
        } catch (e) {
            showToast('Malformed transaction response packet', 'error');
        }
    })
    .catch(() => showToast('Interface timeout', 'error'));
}

function editStaff(button) {
    currentAction = 'update'; // Set status operasi "UPDATE"
    const row = button.closest('tr');
    const staffId = row.getAttribute('data-id');
    const cells = row.cells;
    
    document.getElementById('modalTitle').innerHTML = '<i class="fas fa-edit"></i> Edit Staff';
    
    const idInput = document.getElementById('staffId');
    idInput.value = staffId;
    idInput.disabled = true; // Kunci input ID semasa fasa edit (Primary key protection)
    
    document.getElementById('staffName').value = cells[1].textContent;
    document.getElementById('staffPassword').value = ''; // Kosongkan input password demi sekuriti
    
    document.getElementById('staffModal').style.display = 'block';
}

function deleteStaff(staffId) {
    if (confirm('Are you sure you want to delete this staff member?')) {
        const params = new URLSearchParams();
        params.append('action', 'delete');
        params.append('id', staffId);
        
        fetch('staff_ajax.jsp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params
        })
        .then(response => response.text())
        .then(text => {
            try {
                const data = JSON.parse(text);
                if (data.success) {
                    loadStaffFromDatabase();
                    showToast('Staff records deleted.');
                } else {
                    showToast('Delete process failed', 'error');
                }
            } catch (e) {
                showToast('Error processing data stream', 'error');
            }
        });
    }
}

window.editStaff = editStaff;
window.deleteStaff = deleteStaff;