(function ($) {
    function _openPage(_parent, page) {
        var _settings = _parent.data("_psettings");
        var pageOptCount = _settings.pageOptCount;
        var start = page - Math.floor(pageOptCount / 2);
        var pageCount = _settings.pageCount;

        if (page <= 1) {
            page = 1;
            start = 1;
        } else if (page >= pageCount) {
            page = pageCount;
            start = pageCount - (pageOptCount - 1);
        } else if (page >= pageCount - (pageOptCount - 1)) {
            start = pageCount - (pageOptCount - 1);
        }
        if (start < 1) {
            start = 1;
        }

        var btPages = _parent.find("a.page");
        var numbtPage = btPages.size();
        var btPage;
        for (var i = 0; i < numbtPage; i++) {
            btPage = $(btPages[i]);
            btPage.attr("data-page", i + start).text(i + start);
        }
        btPages.parent().removeClass("active");
        btPages.filter('[data-page="' + page + '"]').parent().addClass("active");
        _settings.page = page;
    }

    var _methods = {
        init: function (options) {
            return this.each(function () {
                var _settings = $.extend(true, {
                    page: 1,
                    pageCount: 1,
                    pageOptCount: 1,
                    onBackward: function (s, e) { },
                    onForward: function (s, e) { },
                    onNext: function (s, e) { },
                    onPrevious: function (s, e) { }
                }, options);
                var _parent = $(this);
                _parent.data("_psettings", _settings);
                _parent.find("a.first").click(function () { _openPage(_parent, 1); });
                _parent.find("a.last").click(function () { _openPage(_parent, _settings.pageCount); });
                _parent.find("a.next").click(function () { _openPage(_parent, _settings.page + 1); });
                _parent.find("a.prev").click(function () { _openPage(_parent, _settings.page - 1); });
                _openPage(_parent, _settings.page);
            });
        }
    };

    $.fn.tdkPaginator = function (options, args) {
        var _parent = $(this);
        if (!_parent.data("_psettings")) {
            return _methods.init.call(this, options);
        } else if (_methods[options]) {
            return _methods[options].call(this, args);
        }
    }
})(jQuery);