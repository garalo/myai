// Main application JavaScript
document.addEventListener('DOMContentLoaded', () => {
    // Model selection auto-submit
    const modelSelect = document.querySelector('.model-select');
    if (modelSelect) {
        modelSelect.addEventListener('change', () => {
            modelSelect.closest('form').submit();
        });
    }

    // Optional: Add auto-focus to textarea on home page
    const promptArea = document.getElementById('text');
    if (promptArea) {
        promptArea.focus();
    }
});
