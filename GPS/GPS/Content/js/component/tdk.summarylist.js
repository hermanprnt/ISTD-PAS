(function ($) {
    var _methods = {
        select: function (key) {
            var _settings = _parent.data("_psettings");
            var summaries = _parent.find("a.summary");
            summaries.removeClass("active");
            var size = summaries.size();
            var anchor;
            for (var i = 0; i < size; i++) {
                anchor = summaries[i];
                k = anchor.attr("data-key");
                if ((k != "") && (k === key)) {
                    anchor.addClass("active");
                    if ((_settings.onSummaryClicked != undefined) && (_settings.onSummaryClicked instanceof Function)) {
                        _settings.onSummaryClicked.call($(this));
                    }
                    break;
                }
            }
        },
        init: function (options) {
            return this.each(function () {
                var _settings = $.extend(true, {
                    callbackRoute: "#",
                    pageSize: 5,
                    totalData: 0,
                    totalPage: 1,
                    currentPage: 1,
                    enableBackendProcessing: false,
                    onSummaryClicked: function () { }
                }, options);
                var _parent = $(this);
                _parent.data("_psettings", _settings);
                _parent.find(".content").dotdotdot({ height: 50 });
                var summaries = _parent.find("a.summary");
                var numSummary = summaries.length;
                summaries.click(function () {
                    summaries.removeClass("active");
                    $(this).addClass("active");
                    if ((_settings.onSummaryClicked != undefined) && (_settings.onSummaryClicked instanceof Function)) {
                        _settings.onSummaryClicked.call($(this));
                    }
                });

                if (!_settings.enableBackendProcessing) {
                    var pageSize = _settings.pageSize;
                    var totalData = _settings.totalData;
                    var totalPage = Math.floor(totalData / pageSize);
                    if ((totalData % pageSize) > 0) {
                        totalPage++;
                    }
                    _settings.totalPage = totalPage;
                    _parent.find(".total-page").text(totalPage);
                    _openPage(_parent, 1);
                }

                var footer = _parent.find(".panel-footer").first();
                var paginator = footer.children(".paginator").first();
                paginator.find("button.forward").click(function () { _forward(_parent); });
                paginator.find("button.backward").click(function () { _backward(_parent); });
                paginator.find("button.previous").click(function () { _prev(_parent); });
                paginator.find("button.next").click(function () { _next(_parent); });
            });
        }
    };

    function _next(_parent) {
        var _settings = _parent.data("_psettings");
        _openPage(_parent, _settings.currentPage + 1);
    }

    function _prev(_parent) {
        var _settings = _parent.data("_psettings");
        _openPage(_parent, _settings.currentPage - 1);
    }

    function _backward(_parent) {
        _openPage(_parent, 1);
    }

    function _forward(_parent) {
        var _settings = _parent.data("_psettings");
        _openPage(_parent, _settings.totalPage);
    }

    function _openPage(_parent, page) {
        var summaries = _parent.find("a.summary");
        var _settings = _parent.data("_psettings");
        var pageSize = _settings.pageSize;
        var totalData = _settings.totalData;
        var totalPage = _settings.totalPage;
        var startIndex = (page - 1) * _settings.pageSize;
        var endIndex = page * _settings.pageSize;
        if (page <= 1) {
            page = 1;
            _parent.find("button.next").prop("disabled", false);
            _parent.find("button.forward").prop("disabled", false);
            _parent.find("button.backward").prop("disabled", true);
            _parent.find("button.previous").prop("disabled", true);
        } else if (page >= totalPage) {
            page = totalPage;
            endIndex = totalData;
            _parent.find("button.next").prop("disabled", true);
            _parent.find("button.forward").prop("disabled", true);
            _parent.find("button.backward").prop("disabled", false);
            _parent.find("button.previous").prop("disabled", false);
        } else {
            _parent.find("button.next").prop("disabled", false);
            _parent.find("button.previous").prop("disabled", false);
        }

        summaries.hide();
        for (var i = startIndex; i < endIndex; i++) {
            $(summaries[i]).show();
        }
        _settings.currentPage = page;
        _parent.find("input.page-input").val(_settings.currentPage);
    }

    $.fn.tdkSummaryList = function (options, args) {
        var _parent = $(this);
        if (!_parent.data("_psettings")) {
            return _methods.init.call(this, options);
        } else if (_methods[options]) {
            return _methods[options].call(this, args);
        }
    }
})(jQuery);