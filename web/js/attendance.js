/**
 * Attendance JavaScript
 * Handle form validation and submission
 */

document.addEventListener('DOMContentLoaded', function() {
    initFormValidation();
    initAttendeeIdValidation();
});

// Form validation
function initFormValidation() {
    const form = document.getElementById('attendanceForm');
    if (!form) return;
    
    form.addEventListener('submit', function(e) {
        const attendeeId = document.getElementById('attendeeId');
        
        // Clear previous errors
        clearErrors();
        
        let hasError = false;
        
        // Validate Attendee ID
        if (!attendeeId.value.trim()) {
            showError(attendeeId, 'Please enter your Attendee ID');
            hasError = true;
        } else if (attendeeId.value.trim().length < 1) {
            showError(attendeeId, 'Please enter a valid Attendee ID');
            hasError = true;
        }
        
        if (hasError) {
            e.preventDefault();
        }
    });
}

// Attendee ID validation (format check)
function initAttendeeIdValidation() {
    const attendeeIdInput = document.getElementById('attendeeId');
    if (!attendeeIdInput) return;
    
    attendeeIdInput.addEventListener('input', function() {
        // Clear error when typing
        const error = this.parentElement.querySelector('.field-error');
        if (error) error.remove();
        this.style.borderColor = '#e8dfd5';
    });
}

// Show error message
function showError(inputElement, message) {
    const errorDiv = document.createElement('div');
    errorDiv.className = 'field-error';
    errorDiv.style.cssText = 'color: #c62828; font-size: 0.7rem; margin-top: 0.3rem; margin-left: 0.5rem;';
    errorDiv.innerHTML = `<i class="fas fa-exclamation-circle"></i> ${message}`;
    
    inputElement.parentElement.appendChild(errorDiv);
    inputElement.style.borderColor = '#c62828';
}

// Clear all errors
function clearErrors() {
    const errors = document.querySelectorAll('.field-error');
    errors.forEach(error => error.remove());
    
    const inputs = document.querySelectorAll('input');
    inputs.forEach(input => {
        input.style.borderColor = '#e8dfd5';
    });
}