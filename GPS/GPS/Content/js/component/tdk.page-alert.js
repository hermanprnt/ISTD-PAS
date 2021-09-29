(function ($) {
    $tdk.ALERT_SEVERITY_ERROR = 3;
    $tdk.ALERT_SEVERITY_WARNING = 2;
    $tdk.ALERT_SEVERITY_SUCCESS = 1;
    $tdk.ALERT_SEVERITY_INFO = 0;

    var _methods = {
        init: function (options) {
            var _parent = $(this);
            var _settings = $.extend();
            _parent.data("_psettings", _settings);
        }
    };
    $.fn.tdkAlert = function (options, args) {
        var _parent = $(this);
        if (!_parent.data("_psettings")) {
            return _methods.init.call(this, options);
        } else if (_methods[options]) {
            return _methods[options].call(this, args);
        }
    }
})(jQuery);