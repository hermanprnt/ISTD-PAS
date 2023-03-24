!function ($) {
    "use strict";

    $.disable_enable_button = {
        disable: function () {
            $(".btndisable").attr('disabled', true);
            var loading = document.getElementById('progress-loading');
            loading.style.display = "block";
        },

        enable: function () {
            $(".btndisable").attr('disabled', false);
            var loading = document.getElementById('progress-loading');
            loading.style.display = "none";
        }
    }

} (window.jQuery);