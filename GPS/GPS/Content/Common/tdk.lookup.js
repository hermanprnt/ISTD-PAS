!function ($) {
    "use strict";

    $.fn.lookup = function (options) {

        var $settings = $.extend({}, {
            LookupOpenUrl: "",
            LookupSearchUrl: "",
            IsSingleSelection: false,
            IsSearchTextReset: false,
            AdditionalParam: [],
            DataName: "",
            SelectedFormatter: function (data) {
                // NOTE: default data is NameValueItem
                return data.Value + " - " + data.Name;
            },
            OnBeginCallback: function () { },
            OnEndCallback: function () { },
            OnLookupButtonClick: function () { return true; },
            OnLookupButtonClicked: function () { },
            OnLookupSuccessCallback: function (data) { },
            OnLookupErrorCallback: function (data) {
                console.log("Lookup Error:\r\n");
                console.log(data);
                throw new Error(JSON.stringify(data));
            },
            OnSearchButtonClick: function () { },
            OnSearchButtonClicked: function () { },
            OnSearchSuccessCallback: function (data) { },
            OnSearchErrorCallback: function (data) {
                console.log("Search Error:\r\n");
                console.log(data);
                throw new Error(JSON.stringify(data));
            },
            OnClearButtonClick: function () { },
            OnClearButtonClicked: function () { },
            OnOkButtonClick: function () {
                if (!$settings.IsSingleSelection) {
                    var selectedArray = [];
                    $($chks.selector + ":checked").each(function (idx, el) {
                        selectedArray.push($(this).data("key") + " - " + $(this).data("value"));
                    });
                    $txtlookup.val(selectedArray.join(";"));
                }
            },
            OnOkButtonClicked: function () {
                $popuplookup.modal("hide");
            },
            OnCancelButtonClick: function () { },
            OnCancelButtonClicked: function () {
                $popuplookup.modal("hide");
            },
            OnRowSelected: function (selected) {
                console.log(selected);
                $popuplookup.modal("hide");
            }
        }, options);

        if ($settings.LookupOpenUrl === "" &&
            $settings.LookupSearchUrl === "") {
            throw new InvalidOperationException("options must have LookupOpenUrl and LookupSearchUrl value");
        }

        var $lookup = $(this);
        if ($lookup.length === 0)
            throw new InvalidOperationException($lookup.selector + " is undefined");
        var $splitteddataname = $lookup.attr("id").split("-");
        var $dataname = $splitteddataname.slice(1, $splitteddataname.length).join("-");
        if ($settings.DataName !== "")
            $dataname = $settings.DataName;
        var $txtlookup = $lookup.find("input[type=text][id^=txtlookup-]");
        var $btnlookup = $lookup.find("button[id^=btnlookup-]");
        var $popuplookup = $(document).find("#" + $lookup.data("popupid"));
        var $txtfilter, $btnfilter, $btnclearfilter, $chkall, $datagrid, $chks, $btnok, $btncancel, $currentpage, $pagesize;

        function InitElement() {
            $txtfilter = $popuplookup.find("input[type=text][id^=txtfilter-]");
            $btnfilter = $popuplookup.find("button[id^=btnfilter-]");
            $btnclearfilter = $popuplookup.find("button[id^=btnclearfilter-]");
            $chkall = $popuplookup.find("input[type=checkbox][id^=chkall-]");
            $datagrid = $popuplookup.find("div[id^=datagrid-]");
            $chks = $datagrid.find("table input[type=checkbox][id^=chk-]");
            $btnok = $popuplookup.find("button[class*=btn-action][data-role=select-lookup]");
            $btncancel = $popuplookup.find("button[class*=btn-action][data-role=dismiss-lookup]");
        }

        function InitEvent() {
            var $searchresponse = window["Search" + $dataname + "ResponseCallback"] = function (data) {
                if (!data.ResponseType) {
                    $datagrid.html(data);
                    $settings.OnSearchSuccessCallback(data);
                    Init();
                }
                else {
                    $settings.OnSearchErrorCallback(data);
                }
            };

            var $search = window["Search" + $dataname] = function (page, pageSize, responseCallback) {

                $settings.OnBeginCallback();

                $currentpage = page;
                $pagesize = pageSize;
                var searchParam = MergeAdditionalParam({
                    SearchText: $txtfilter.valOrDefault(),
                    CurrentPage: $currentpage,
                    PageSize: $pagesize
                });

                $.ajax({
                    type: "POST",
                    url: $settings.LookupSearchUrl,
                    data: JSON.stringify(searchParam),
                    contentType: "application/json; charset=utf-8",
                    success: responseCallback,
                    complete: function () {
                        $settings.OnEndCallback();
                    },
                    error: function (data) {
                        $settings.OnSearchErrorCallback(data);
                    }
                });
            };

            $(document).onOnce("click", "#" + $btnlookup.attr("id"), function (e) {

                if (!$settings.OnLookupButtonClick())
                    return;

                $txtfilter.val("");
                $chkall.prop("checked", false);
                $chks.prop("checked", false);

                if ($popuplookup.hasClass("in")) {
                    $settings.OnLookupButtonClicked();
                    $popuplookup.modal("hide");
                }
                else {
                    $settings.OnBeginCallback();

                    var openParam = MergeAdditionalParam({
                        SearchText: $txtfilter.valOrDefault(),
                        CurrentPage: $currentpage,
                        PageSize: $pagesize
                    });

                    $.ajax({
                        type: "POST",
                        url: $settings.LookupOpenUrl,
                        data: JSON.stringify(openParam),
                        contentType: "application/json; charset=utf-8",
                        success: function (data) {
                            if (!data.ResponseType) {
                                $popuplookup.html(data);
                                $settings.OnLookupSuccessCallback(data);
                                Init();
                                $settings.OnLookupButtonClicked();
                                $popuplookup.modal();
                            }
                            else {
                                $settings.OnLookupErrorCallback(data);
                            }
                        },
                        complete: function () {
                            $settings.OnEndCallback();
                        },
                        error: function (data) {
                            $settings.OnLookupErrorCallback(data);
                        }
                    });
                }
            });

            $(document).onOnce("click", $btnfilter.selector, function (e) {

                $settings.OnSearchButtonClick();
                ResetPaging();
                $search($currentpage, $pagesize, $searchresponse);
                $settings.OnSearchButtonClicked();
            });

            $(document).onOnce("click", $btnclearfilter.selector, function (e) {

                $settings.OnClearButtonClick();
                ResetSearchText();
                ResetPaging();
                $search($currentpage, $pagesize, $searchresponse);
                $settings.OnClearButtonClicked();
            });

            $(document).onOnce("change", "#" + $chkall.attr("id"), function (e) {
                var isChecked = $(this).prop("checked");
                $chks.each(function (idx, el) {
                    $(this).prop("checked", isChecked);
                });
            });

            $(document).onOnce("change", $chks.selector, function (e) {
                var isCheckedAll = $($chks.selector + ":checked").length === $chks.length;
                $chkall.prop("checked", isCheckedAll);
            });

            $(document).onOnce("click", $btnok.selector, function (e) {
                $settings.OnOkButtonClick();
                $settings.OnOkButtonClicked();
            });

            $(document).onOnce("click", $btncancel.selector, function (e) {
                $settings.OnCancelButtonClick();
                $settings.OnCancelButtonClicked();
            });

            $(document).onOnce("keyup", $txtfilter.selector, function (e) {
                // NOTE: 13 is Enter
                if (e.keyCode === 13) {
                    $btnfilter.trigger("click");
                }
            });
        }

        function ResetSearchText() {
            $txtfilter.val("");
            $txtfilter.trigger("focus");
        }

        function ResetPaging() {
            $currentpage = 1;
            $pagesize = 10;
        }

        function SingleSelectionMode() {
            $($datagrid.selector + " table .col-check").addClass("hidden");

            $(document).onOnce("dblclick", $datagrid.selector + " table > tbody > tr", function (e) {
                var selectedData = $(this).data("value"); // NOTE: JSON is already parsedby jquery
                var formattedData = $settings.SelectedFormatter(selectedData);
                $txtlookup.val(formattedData);
                $settings.OnRowSelected(selectedData);
            });
        }

        function MergeAdditionalParam(searchParam) {
            var additionalParam = $settings.AdditionalParam;
            if (additionalParam.length > 0) {
                var param = {};
                additionalParam.forEach(function (el, idx) {
                    switch (el.Type) {
                        case "D": // NOTE: D --> direct value
                            param[el.Name] = el.Value;
                            break;
                        case "I": // NOTE: I --> indirect value / it's value is control's selector to get real value from
                            param[el.Name] = $(el.Value).valOrDefault();
                            break;
                        case "C": // NOTE: C --> callback value which need to be executed
                            param[el.Name] = el.Value();
                            break;
                    }
                });
                $.extend(searchParam, param);
            }

            return searchParam;
        }

        function Init() {
            InitElement();
            InitEvent();
            ResetPaging();
            if ($settings.IsSingleSelection)
                SingleSelectionMode();
            if ($settings.IsSearchTextReset)
                ResetSearchText();
        }

        Init();
    }

    $.fn.LookupVal = function(value) {
        var $lookup = $(this);
        if (value === undefined) {
            var $lookupval = $lookup.valOrDefault();
            if ($lookup.hasClass("lookup")) {
                $lookupval = $lookup
                    .find("input[type=text][id^=txtlookup-]")
                    .valOrDefault();
            }

            return $lookupval.split(" - ")[0];
        }
        else {
            $lookup.val(value);
            if ($lookup.hasClass("lookup")) {
                $lookup
                    .find("input[type=text][id^=txtlookup-]")
                    .val(value);
            }

            return undefined;
        }
    }

    function Disable (idList, isDisabled) {
        if (GetType(idList) !== "Array")
            throw new InvalidOperationException("idList of DisableLookup must be an Array of selector.");

        idList.forEach(function (item) {
            var $item = $(item);
            if ($item.hasClass("lookup")) {
                var btnlookup = $item.find("button[id^=btnlookup-]");
                if (isDisabled) {
                    $item.find("input[id^=txtlookup-]").addClass("lookup-disabled");
                    btnlookup.addClass("lookup-disabled");
                }
                else {
                    $item.find("input[id^=txtlookup-]").removeClass("lookup-disabled");
                    btnlookup.removeClass("lookup-disabled");
                }
                btnlookup.prop("disabled", isDisabled);
            }
        });
    }

    $.DisableLookup = function (idList) { Disable(idList, true); }
    $.EnableLookup = function (idList) { Disable(idList, false); }

    $.ClearLookup = function (idList) {
        if (GetType(idList) !== "Array")
            throw new InvalidOperationException("idList of ClearLookup must be an Array of selector.");

        idList.forEach(function (item) {
            $(item).LookupVal("");
        });
    };

}(window.jQuery);