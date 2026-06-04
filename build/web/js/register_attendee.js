/**
 * Register Attendee JavaScript
 * Handle form validation and submission
 */

document.addEventListener('DOMContentLoaded', function() {
    initFormValidation();
    initPhoneValidation();
});

// Form validation
function initFormValidation() {
    const form = document.getElementById('registrationForm');
    if (!form) return;
    
    form.addEventListener('submit', function(e) {
        const name = document.getElementById('name');
        const phone = document.getElementById('phone');
        
        // Clear previous errors
        clearErrors();
        
        let hasError = false;
        
        // Validate name
        if (!name.value.trim()) {
            showError(name, 'Please enter your full name');
            hasError = true;
        } else if (name.value.trim().length < 3) {
            showError(name, 'Name must be at least 3 characters');
            hasError = true;
        }
        
        // Validate phone
        if (!phone.value.trim()) {
            showError(phone, 'Please enter your phone number');
            hasError = true;
        } else if (!validatePhone(phone.value.trim())) {
            showError(phone, 'Please enter a valid phone number (e.g., 012-3456789)');
            hasError = true;
        }
        
        if (hasError) {
            e.preventDefault();
        }
    });
}

// Phone number validation
function initPhoneValidation() {
    const phoneInput = document.getElementById('phone');
    if (!phoneInput) return;
    
    phoneInput.addEventListener('input', function() {
        // Auto-format phone number
        let value = this.value.replace(/\D/g, '');
        if (value.length >= 3 && value.length <= 4) {
            this.value = value;
        } else if (value.length > 4 && value.length <= 7) {
            this.value = value.slice(0, 3) + '-' + value.slice(3);
        } else if (value.length > 7) {
            this.value = value.slice(0, 3) + '-' + value.slice(3, 7) + '-' + value.slice(7, 11);
        }
        
        // Clear error when typing
        const error = this.parentElement.querySelector('.field-error');
        if (error) error.remove();
        this.style.borderColor = '#e8dfd5';
    });
}

// Validate phone number (Malaysia format)
function validatePhone(phone) {
    const phoneRegex = /^(\+?6?01)[0-9\-]{8,10}$|^[0-9]{3}-[0-9]{7,8}$/;
    return phoneRegex.test(phone) || phone.replace(/\D/g, '').length >= 10;
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

// Show success message (if needed)
function showSuccess(message) {
    const successDiv = document.createElement('div');
    successDiv.className = 'message success';
    successDiv.innerHTML = `<i class="fas fa-check-circle"></i> ${message}`;
    
    const formSection = document.querySelector('.form-section');
    if (formSection) {
        formSection.insertBefore(successDiv, formSection.firstChild);
        setTimeout(() => successDiv.remove(), 5000);
    }
}