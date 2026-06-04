/**
 * Smart RSVP Management System
 * Frontend JavaScript - Clean & Optimized
 */

// ========================================
// DOM Content Loaded Handler
// ========================================
document.addEventListener('DOMContentLoaded', function() {
    initPasswordToggle();
    initFormValidation();
    initModalHandlers();
    initLogoFallback();
    clearModalOnInput();
    console.log('Smart RSVP Ready');
});

// ========================================
// 1. PASSWORD TOGGLE VISIBILITY
// ========================================
function initPasswordToggle() {
    const toggleBtn = document.getElementById('togglePasswordBtn');
    const passwordField = document.getElementById('passwordField');
    
    if (toggleBtn && passwordField) {
        toggleBtn.addEventListener('click', function() {
            const type = passwordField.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordField.setAttribute('type', type);
            this.textContent = type === 'password' ? '👁️' : '🙈';
        });
    }
}

// ========================================
// 2. FORM VALIDATION
// ========================================
function initFormValidation() {
    const loginForm = document.getElementById('loginForm');
    
    if (loginForm) {
        loginForm.addEventListener('submit', function(e) {
            const username = document.getElementById('username');
            const password = document.getElementById('passwordField');
            
            if (!username.value.trim()) {
                e.preventDefault();
                showErrorPopup('⚠️ Username is required');
                return false;
            }
            
            if (!password.value) {
                e.preventDefault();
                showErrorPopup('⚠️ Password is required');
                return false;
            }
            
            return true;
        });
    }
}

// ========================================
// 3. MODAL / POPUP HANDLERS
// ========================================
function initModalHandlers() {
    const closeBtn = document.querySelector('.close-btn');
    const modalCloseBtn = document.querySelector('.modal-close-btn');
    const modal = document.getElementById('errorModal');
    
    // Close buttons
    if (closeBtn) closeBtn.addEventListener('click', closeModal);
    if (modalCloseBtn) modalCloseBtn.addEventListener('click', closeModal);
    
    // Close when clicking outside modal
    if (modal) {
        modal.addEventListener('click', function(event) {
            if (event.target === modal) closeModal();
        });
    }
    
    // Close with Escape key
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') closeModal();
    });
}

// Show error popup modal
function showErrorPopup(message) {
    const modal = document.getElementById('errorModal');
    const errorText = document.getElementById('errorMessageText');
    
    if (modal && errorText) {
        errorText.textContent = message;
        modal.style.display = 'block';
        document.body.style.overflow = 'hidden';
    } else {
        alert(message); // Fallback if modal not found
    }
}

// Close modal function
function closeModal() {
    const modal = document.getElementById('errorModal');
    if (modal && modal.style.display === 'block') {
        modal.style.display = 'none';
        document.body.style.overflow = 'auto';
    }
}

// Make functions available globally
window.showErrorPopup = showErrorPopup;
window.closeModal = closeModal;

// ========================================
// 4. CLEAR MODAL WHEN USER STARTS TYPING
// ========================================
function clearModalOnInput() {
    const inputs = document.querySelectorAll('#username, #passwordField');
    inputs.forEach(input => {
        input.addEventListener('input', function() {
            closeModal();
        });
    });
}

// ========================================
// 5. LOGO IMAGE FALLBACK
// ========================================
function initLogoFallback() {
    const logoImg = document.getElementById('logoImage');
    
    if (logoImg) {
        logoImg.addEventListener('error', function() {
            this.style.display = 'none';
            const logoArea = document.querySelector('.logo-area');
            
            if (logoArea) {
                const fallback = document.createElement('div');
                fallback.className = 'logo-fallback';
                fallback.textContent = 'RSVP';
                logoArea.appendChild(fallback);
            }
        });
    }
}