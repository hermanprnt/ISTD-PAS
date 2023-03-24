(function ($) {
    function _setCheckState(_parent, checked) {
        var _settings = _parent.data("_psettings");
        var input = _parent.find("input:checkbox").first();
        var glyph = _parent.find("i").first();

        input.prop("checked", checked);
        var uncheckClass = "fa-square-o";
        var checkClass = "fa-check-square-o";
        if (_parent.hasClass("inverse")) {
            uncheckClass = "fa-square";
            checkClass = "fa-check-square";
        }

        if (checked) {
            glyph.removeClass(uncheckClass).addClass(checkClass + " checked");
        } else {
            glyph.removeClass(checkClass + " checked").addClass(uncheckClass);
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
                var input = _parent.find("input:checkbox").first();
                input.prop("checked", false);
                input.hide();

                var glyph = $("<i/>", {
                    addClass: "fa fa-lg"
                });
                glyph.click(function () {
                    var input = _parent.find("input:checkbox").first();
                    var checked = input.prop("checked");
                    input.prop("checked", !checked);
                    _setCheckState(_parent, !checked);
                });
                _parent.prepend(glyph);
                _setCheckState(_parent, _settings.checked);
            });
        },
        checked: function (check) {
            if (check != undefined) {
                _setCheckState($(this), check);
            } else {
                return $(this).find("input:checkbox").first().prop("checked");
            }
        }
    };

    $.fn.tdkCheckBox = function (options, args) {
        var _parent = $(this);
        if (!_parent.data("_psettings")) {
            return _methods.init.call(this, options);
        } else if (_methods[options]) {
            return _methods[options].call(this, args);
        }
    }
})(jQuery);