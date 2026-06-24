/**
 * Hall Management JavaScript
 * Handle add, edit, delete operations
 */

document.addEventListener('DOMContentLoaded', function() {
    initNavigation();
    initModal();
    initFormSubmit();
    loadHallsFromSession();
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
    if (navReport) navReport.onclick = () => window.location.href = 'ReportServlet';
    if (navReservation) navReservation.onclick = () => window.location.href = 'event_list.jsp';
}

// Load halls from session via AJAX
function loadHallsFromSession() {
    fetch('hall_ajax.jsp?action=getAll')
        .then(response => response.text())
        .then(text => {
            try {
                const data = JSON.parse(text);
                if (data.success) {
                    updateTable(data.halls);
                } else {
                    console.error('Failed to load halls:', data.message);
                    showError('Failed to load halls');
                }
            } catch (e) {
                console.error('JSON parse error:', e, text);
                showError('Error loading data');
            }
        })
        .catch(error => {
            console.error('Fetch error:', error);
            showError('Cannot connect to server');
        });
}

// Show error message
function showError(message) {
    const errorDiv = document.createElement('div');
    errorDiv.className = 'error-toast';
    errorDiv.innerHTML = `<i class="fas fa-exclamation-circle"></i> ${message}`;
    errorDiv.style.cssText = `
        position: fixed;
        bottom: 20px;
        right: 20px;
        background: #c62828;
        color: white;
        padding: 12px 20px;
        border-radius: 8px;
        z-index: 2000;
        animation: fadeInOut 3s ease;
    `;
    document.body.appendChild(errorDiv);
    setTimeout(() => errorDiv.remove(), 3000);
}

// Update table with data
function updateTable(halls) {
    const tbody = document.getElementById('hallTableBody');
    if (!tbody) return;
    
    if (!halls || halls.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align: center;">No halls available. Click "+ Add Hall" to create one.</td></tr>';
        return;
    }
    
    tbody.innerHTML = '';
    halls.forEach(hall => {
        const row = tbody.insertRow();
        row.setAttribute('data-id', hall.id);
        
        row.insertCell(0).textContent = hall.id;
        row.insertCell(1).textContent = hall.name;
        row.insertCell(2).textContent = hall.capacity;
        row.insertCell(3).textContent = hall.location;
        
        const statusCell = row.insertCell(4);
        const statusClass = (hall.status || 'Available').toLowerCase();
        statusCell.innerHTML = `<span class="status-badge ${statusClass}">${hall.status || 'Available'}</span>`;
        
        const actionsCell = row.insertCell(5);
        actionsCell.className = 'actions';
        actionsCell.innerHTML = `
            <button class="edit-btn" onclick="editHall(this)"><i class="fas fa-edit"></i> Edit</button>
            <button class="delete-btn" onclick="deleteHall('${hall.id}')"><i class="fas fa-trash-alt"></i> Delete</button>
        `;
    });
}

// Initialize Modal
function initModal() {
    const modal = document.getElementById('hallModal');
    const addBtn = document.getElementById('addHallBtn');
    const closeBtn = document.querySelector('.close-modal');
    
    if (addBtn) {
        addBtn.onclick = () => {
            document.getElementById('modalTitle').innerHTML = '<i class="fas fa-plus-circle"></i> Add New Hall';
            document.getElementById('hallForm').reset();
            document.getElementById('hallId').value = '';
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
    const form = document.getElementById('hallForm');
    if (form) {
        form.onsubmit = (e) => {
            e.preventDefault();
            saveHall();
        };
    }
}

// Save Hall (Add or Edit)
function saveHall() {
    const hallId = document.getElementById('hallId').value;
    const hallName = document.getElementById('hallName').value.trim();
    const hallCapacity = document.getElementById('hallCapacity').value.trim();
    const hallLocation = document.getElementById('hallLocation').value.trim();
    const hallStatus = document.getElementById('hallStatus').value;
    
    if (!hallName) {
        showError('Please enter hall name');
        return;
    }
    if (!hallCapacity) {
        showError('Please enter capacity');
        return;
    }
    if (!hallLocation) {
        showError('Please enter location');
        return;
    }
    
    const url = 'hall_ajax.jsp';
    const params = new URLSearchParams();
    params.append('action', hallId ? 'update' : 'add');
    params.append('id', hallId);
    params.append('name', hallName);
    params.append('capacity', hallCapacity);
    params.append('location', hallLocation);
    params.append('status', hallStatus);
    
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
                document.getElementById('hallModal').style.display = 'none';
                loadHallsFromSession();
                showError('Hall saved successfully!');
            } else {
                showError('Failed to save hall: ' + (data.message || 'Unknown error'));
            }
        } catch (e) {
            console.error('JSON parse error:', e, text);
            showError('Error processing response');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showError('An error occurred');
    });
}

// Edit Hall
function editHall(button) {
    const row = button.closest('tr');
    const hallId = row.getAttribute('data-id');
    const cells = row.cells;
    
    document.getElementById('modalTitle').innerHTML = '<i class="fas fa-edit"></i> Edit Hall';
    document.getElementById('hallId').value = hallId;
    document.getElementById('hallName').value = cells[1].textContent;
    document.getElementById('hallCapacity').value = cells[2].textContent;
    document.getElementById('hallLocation').value = cells[3].textContent;
    
    const statusText = cells[4].querySelector('.status-badge')?.textContent || cells[4].textContent;
    const statusSelect = document.getElementById('hallStatus');
    for (let i = 0; i < statusSelect.options.length; i++) {
        if (statusSelect.options[i].value === statusText) {
            statusSelect.selectedIndex = i;
            break;
        }
    }
    
    document.getElementById('hallModal').style.display = 'block';
}

// Delete Hall with confirmation
function deleteHall(hallId) {
    if (confirm('Are you sure you want to delete this hall?\n\nThis action cannot be undone.')) {
        const url = 'hall_ajax.jsp';
        const params = new URLSearchParams();
        params.append('action', 'delete');
        params.append('id', hallId);
        
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
                    loadHallsFromSession();
                    showError('Hall deleted successfully!');
                } else {
                    showError('Failed to delete hall');
                }
            } catch (e) {
                console.error('JSON parse error:', e);
                showError('Error processing response');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            showError('An error occurred');
        });
    }
}

// Add CSS animation for error toast
const style = document.createElement('style');
style.textContent = `
    @keyframes fadeInOut {
        0% { opacity: 0; transform: translateY(20px); }
        10% { opacity: 1; transform: translateY(0); }
        90% { opacity: 1; transform: translateY(0); }
        100% { opacity: 0; transform: translateY(20px); }
    }
`;
document.head.appendChild(style);