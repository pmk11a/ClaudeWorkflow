/* DAPEN ERP - Card Component Scripts */
/* Extracted from card.blade.php for clean code architecture */

/**
 * Initialize collapsible card functionality
 * @param {string} cardId - The ID of the collapsible card
 */
function initializeCollapsibleCard(cardId) {
    document.addEventListener('DOMContentLoaded', function() {
        // Handle collapse icon rotation
        const collapseElement = document.getElementById(cardId + '-body');
        if (collapseElement) {
            collapseElement.addEventListener('show.bs.collapse', function() {
                const icon = this.parentElement.querySelector('.card-header .fa-chevron-down, .card-header .fa-chevron-up');
                if (icon) {
                    icon.classList.remove('fa-chevron-down');
                    icon.classList.add('fa-chevron-up');
                }
            });

            collapseElement.addEventListener('hide.bs.collapse', function() {
                const icon = this.parentElement.querySelector('.card-header .fa-chevron-down, .card-header .fa-chevron-up');
                if (icon) {
                    icon.classList.remove('fa-chevron-up');
                    icon.classList.add('fa-chevron-down');
                }
            });
        }
    });
}

/**
 * Auto-initialize all collapsible cards on page load
 */
document.addEventListener('DOMContentLoaded', function() {
    // Find all collapsible cards and initialize them
    const collapsibleCards = document.querySelectorAll('[data-collapsible="true"]');
    collapsibleCards.forEach(function(card) {
        const cardId = card.getAttribute('id') || 'card';
        initializeCollapsibleCard(cardId);
    });
});