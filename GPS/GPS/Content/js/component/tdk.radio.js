(function ($) {
    function _setCheckState(_parent, checked) {
        var _settings = _parent.data("_psettings");
        var input = _parent.find("input:radio").first();
        input.prop("checked", checked);
        var glyph = _parent.find("i").first();

        var uncheckClass = "fa-circle-o";
        var checkClass = "fa-check-circle-o";
        if (_parent.hasClass("inverse")) {
            uncheckClass = "fa-circle";
            checkClass = "fa-check-circle";
        }

        if (!checked) {
            glyph.removeClass(checkClass + " checked").addClass(uncheckClass);
        } else {
            glyph.removeClass(uncheckClass).addClass(checkClass + " checked");
        }

        if ((_settings.onChecked != undefined) && (_settings.onChecked instanceof Function)) {
            _settings.onChecked.call(_parent, _parent, {});
        }
    }

    var _methods = {
        init: function (options) {
            return this.each(function () {
                var _settings = $.extend(true, {
                    checked: false,
                    onChecked: function (s, e) { }
                }, options);
                var _parent = $(this);
                _parent.data("_psettings", _settings);
                var input = _parent.find("input:radio").first();
                input.prop("checked", false);
                input.hide();

                var glyph = $("<i/>", { addClass: "fa fa-lg" }).prependTo(_parent);
                glyph.click(function () {
                    var _this = $(this);
                    var checked = input.prop("checked");
                    input.prop("checked", !checked);
                    _setCheckState(_parent, !checked);
                });
                _setCheckState(_parent, _settings.checked);
            });
        },
        checked: function () {
            return $(this).find("input:radio").first().prop("checked");
        }
    };

    $.fn.tdkRadio = function (options, args) {
        var _parent = $(this);
        if (!_parent.data("_psettings")) {
            return _methods.init.call(this, options);
        } else if (_methods[options]) {
            return _methods[options].call(this, args);
        }
    }
})(jQuery);