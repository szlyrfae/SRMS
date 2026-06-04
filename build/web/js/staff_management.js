/**
 * Staff Management JavaScript
 * Handle add, edit, delete operations
 */

document.addEventListener('DOMContentLoaded', function() {
    initNavigation();
    initModal();
    initFormSubmit();
    loadStaffFromSession();
});

// Navigation
function initNavigation() {
    const navDashboard = document.getElementById('navDashboard');
    const navHall = document.getElementById('navHall');
    const navStaff = document.getElementById('navStaff');
    const navReport = document.getElementById('navReport');
    const navReservation = document.getElementById('navReservation');
    
    if (navDashboard) navDashboard.onclick = () => window.location.href = 'staff_dashboard.jsp';
    if (navHall) navHall.onclick = () => window.location.href = 'hall.jsp';
    if (navStaff) navStaff.onclick = () => window.location.href = 'staff.jsp';
    if (navReport) navReport.onclick = () => window.location.href = 'report.jsp';
    if (navReservation) navReservation.onclick = () => window.location.href = 'event_list.jsp';
}

// Load staff from session via AJAX
function loadStaffFromSession() {
    fetch('staff_ajax.jsp?action=getAll')
        .then(response => response.text())
        .then(text => {
            try {
                const data = JSON.parse(text);
                if (data.success) {
                    updateTable(data.staff);
                } else {
                    console.error('Failed to load staff:', data.message);
                    showToast('Failed to load staff', 'error');
                }
            } catch (e) {
                console.error('JSON parse error:', e, text);
                showToast('Error loading data', 'error');
            }
        })
        .catch(error => {
            console.error('Fetch error:', error);
            showToast('Cannot connect to server', 'error');
        });
}

// Show toast message
function showToast(message, type) {
    const toast = document.createElement('div');
    toast.className = `error-toast ${type === 'success' ? 'success-toast' : ''}`;
    toast.innerHTML = `<i class="fas ${type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle'}"></i> ${message}`;
    document.body.appendChild(toast);
    setTimeout(() => toast.remove(), 3000);
}

// Update table with data
function updateTable(staffList) {
    const tbody = document.getElementById('staffTableBody');
    if (!tbody) return;
    
    if (!staffList || staffList.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align: center;">No staff available. Click "+ Add Staff" to create one.</td></tr>';
        return;
    }
    
    tbody.innerHTML = '';
    staffList.forEach(staff => {
        const row = tbody.insertRow();
        row.setAttribute('data-id', staff.id);
        
        row.insertCell(0).textContent = staff.id;
        row.insertCell(1).textContent = staff.name;
        row.insertCell(2).textContent = staff.position;
        row.insertCell(3).textContent = staff.email;
        row.insertCell(4).textContent = staff.phone;
        
        const statusCell = row.insertCell(5);
        const statusClass = (staff.status || 'Active').toLowerCase();
        statusCell.innerHTML = `<span class="status-badge ${statusClass}">${staff.status || 'Active'}</span>`;
        
        const actionsCell = row.insertCell(6);
        actionsCell.className = 'actions';
        actionsCell.innerHTML = `
            <button class="edit-btn" onclick="editStaff(this)"><i class="fas fa-edit"></i> Edit</button>
            <button class="delete-btn" onclick="deleteStaff('${staff.id}')"><i class="fas fa-trash-alt"></i> Delete</button>
        `;
    });
}

// Initialize Modal
function initModal() {
    const modal = document.getElementById('staffModal');
    const addBtn = document.getElementById('addStaffBtn');
    const closeBtn = document.querySelector('.close-modal');
    
    if (addBtn) {
        addBtn.onclick = () => {
            document.getElementById('modalTitle').innerHTML = '<i class="fas fa-plus-circle"></i> Add New Staff';
            document.getElementById('staffForm').reset();
            document.getElementById('staffId').value = '';
            modal.style.display = 'block';
        };
    }
    
    if (closeBtn) closeBtn.onclick = () => modal.style.display = 'none';
    
    window.onclick = (event) => {
        if (event.target === modal) modal.style.display = 'none';
    };
}

// Initialize Form Submit
function initFormSubmit() {
    const form = document.getElementById('staffForm');
    if (form) {
        form.onsubmit = (e) => {
            e.preventDefault();
            saveStaff();
        };
    }
}

// Save Staff (Add or Edit)
function saveStaff() {
    const staffId = document.getElementById('staffId').value;
    const staffName = document.getElementById('staffName').value.trim();
    const staffPosition = document.getElementById('staffPosition').value.trim();
    const staffEmail = document.getElementById('staffEmail').value.trim();
    const staffPhone = document.getElementById('staffPhone').value.trim();
    const staffStatus = document.getElementById('staffStatus').value;
    
    if (!staffName) { showToast('Please enter staff name', 'error'); return; }
    if (!staffPosition) { showToast('Please enter position', 'error'); return; }
    if (!staffEmail) { showToast('Please enter email', 'error'); return; }
    if (!staffPhone) { showToast('Please enter phone number', 'error'); return; }
    
    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(staffEmail)) {
        showToast('Please enter a valid email address', 'error');
        return;
    }
    
    const url = 'staff_ajax.jsp';
    const params = new URLSearchParams();
    params.append('action', staffId ? 'update' : 'add');
    params.append('id', staffId);
    params.append('name', staffName);
    params.append('position', staffPosition);
    params.append('email', staffEmail);
    params.append('phone', staffPhone);
    params.append('status', staffStatus);
    
    fetch(url, {
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
                loadStaffFromSession();
                showToast(staffId ? 'Staff updated successfully!' : 'Staff added successfully!', 'success');
            } else {
                showToast('Failed to save staff: ' + (data.message || 'Unknown error'), 'error');
            }
        } catch (e) {
            console.error('JSON parse error:', e, text);
            showToast('Error processing response', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showToast('An error occurred', 'error');
    });
}

// Edit Staff
function editStaff(button) {
    const row = button.closest('tr');
    const staffId = row.getAttribute('data-id');
    const cells = row.cells;
    
    document.getElementById('modalTitle').innerHTML = '<i class="fas fa-edit"></i> Edit Staff';
    document.getElementById('staffId').value = staffId;
    document.getElementById('staffName').value = cells[1].textContent;
    document.getElementById('staffPosition').value = cells[2].textContent;
    document.getElementById('staffEmail').value = cells[3].textContent;
    document.getElementById('staffPhone').value = cells[4].textContent;
    
    const statusText = cells[5].querySelector('.status-badge')?.textContent || cells[5].textContent;
    const statusSelect = document.getElementById('staffStatus');
    for (let i = 0; i < statusSelect.options.length; i++) {
        if (statusSelect.options[i].value === statusText) {
            statusSelect.selectedIndex = i;
            break;
        }
    }
    
    document.getElementById('staffModal').style.display = 'block';
}

// Delete Staff with confirmation
function deleteStaff(staffId) {
    if (confirm('Are you sure you want to delete this staff member?\n\nThis action cannot be undone.')) {
        const url = 'staff_ajax.jsp';
        const params = new URLSearchParams();
        params.append('action', 'delete');
        params.append('id', staffId);
        
        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params
        })
        .then(response => response.text())
        .then(text => {
            try {
                const data = JSON.parse(text);
                if (data.success) {
                    loadStaffFromSession();
                    showToast('Staff deleted successfully!', 'success');
                } else {
                    showToast('Failed to delete staff', 'error');
                }
            } catch (e) {
                console.error('JSON parse error:', e);
                showToast('Error processing response', 'error');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            showToast('An error occurred', 'error');
        });
    }
}