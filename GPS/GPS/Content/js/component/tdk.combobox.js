(function ($) {
    function _performSelection(_parent, option) {
        if (option != undefined) {
            var _settings = _parent.data("_psettings");
            var _text = $.trim(option.text);
            if (_settings.selectedItemPrefix) {
                _parent.find("span.selected-label").text(_settings.selectedItemPrefix + " : " + _text);
            } else {
                _parent.find("span.selected-label").text(_text);
            }
            _parent.data("_pval", $.trim(option.value.toString()));
            _parent.data("_ptext", _text);
            if ((_settings.onSelectedItemChanged != undefined) && (_settings.onSelectedItemChanged instanceof Function)) {
                _settings.onSelectedItemChanged(_parent, _parent, {});
            }
            _settings.onSelectedItemChanged.call(_parent);
        }
    }
    function _getOption(_parent, value) {
        var anchors = _parent.find("ul.dropdown-menu").find("a");
        var _val, _text, _anchor;
        value = $.trim(value);
        for (var i = anchors.size() - 1; i >= 0; i--) {
            _anchor = $(anchors[i]);
            _val = _anchor.attr("data-value");
            _text = _anchor.text();
            if (_val === value) {
                return { text: _text, value: _val };
            }
        }
    }
    var _methods = {
        init: function (options) {
            return this.each(function () {
                var _parent = $(this);
                var _settings = $.extend(true, {
                    selectedValue: null,
                    selectedItemPrefix: null,
                    onSelectedItemChanged: function (s, e) { }
                }, options);
                _parent.data("_psettings", _settings);

                var anchor;
                _parent.find("ul.dropdown-menu").find("a").click(function (e) {
                    e.preventDefault();
                    anchor = $(this);
                    _performSelection(_parent, { text: anchor.text(), value: anchor.attr("data-value") });
                });
                if (_settings.selectedValue != null) {
                    _performSelection(_parent, _getOption(_parent, _settings.selectedValue));
                }
            });
        },
        value: function (val) {
            var _parent = $(this);
            var _settings = _parent.data("_psettings");
            if (val == undefined) {
                return _parent.data("_pval");
            } else {
                _performSelection(_parent, _getOption(_parent, val));
            }
        }
    };

    $.fn.tdkComboBox = function (options, args) {
        var _parent = $(this);
        if (!_parent.data("_psettings")) {
            return _methods.init.call(this, options);
        } else if (_methods[options]) {
            return _methods[options].call(this, args);
        }
    }
})(jQuery);