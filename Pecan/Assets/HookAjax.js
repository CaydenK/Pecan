
(function () {
    if (window.realXMLHttpRequest) {
        return
    }
    var uniqueId = 1;


    window.realXMLHttpRequest = XMLHttpRequest;

    function BaseHookAjax() { }
    BaseHookAjax.prototype = window.realXMLHttpRequest;
    function hookAjax() { }
    hookAjax.prototype = BaseHookAjax;
    hookAjax.prototype.readyState = 0;
    hookAjax.prototype.responseText = "";
    hookAjax.prototype.responseHeaders = {};
    hookAjax.prototype.status = 0;
    hookAjax.prototype.statusText = "";
    hookAjax.prototype.onreadystatechange = null;
    hookAjax.prototype.onload = null;
    hookAjax.prototype.onerror = null;
    hookAjax.prototype.onabort = null;
    hookAjax.prototype.open = function () {
        this.open_arguments = arguments;
        this.readyState = 1;
        if (this.onreadystatechange) {
            this.onreadystatechange()
        }
    };
    hookAjax.prototype.setRequestHeader = function (name, value) {
        if (!this._headers) {
            this._headers = {}
        }
        this._headers[name] = value
    };
    hookAjax.prototype.send = function () {
        var taskName = 'task_' + (uniqueId++) + '_' + new Date().getTime();
        this.taskName = taskName;

        var message = {};
        message.data = arguments;
        message.method = this.open_arguments[0];
        message.url = this.open_arguments[1];
        message.headers = this._headers;

        AjaxBridgeEvent.addHandler(taskName,'stateChange',(callbackMessage)=>{
            if (!this.is_abort) {
                this.status = callbackMessage.status;
                this.responseText = (!!callbackMessage.data) ? callbackMessage.data : "";
                this.responseHeaders = callbackMessage.headers;
                this.readyState = 4
            } else {
                this.readyState = 1
            }
            this.callbackStateChanged();
        })
        AjaxBridge.callNative(taskName,'send',message)
    };
    hookAjax.prototype.callbackStateChanged = function () {
        if (this.readyState >= 3) {
            if (this.status >= 200 && this.status < 300) {
                this.statusText = "OK"
            } else {
                this.statusText = "Fail"
            }
        }
        if (this.onreadystatechange) {
            this.onreadystatechange()
        }
        if (this.readyState == 4) {
            if (this.statusText == "OK") {
                this.onload ? this.onload() : ""
            } else {
                this.onerror ? this.onerror() : ""
            }
        }
    };
    hookAjax.prototype.abort = function () {
        AjaxBridge.callNative(this.taskName,'abort',{})
        this.is_abort = true;
        if (this.onabort) {
            this.onabort()
        }
    };
    hookAjax.prototype.getAllResponseHeaders = function () {
        if (this._xhr) {
            return this._xhr.getAllResponseHeaders()
        } else {
            return this.responseHeaders
        }
    };
    hookAjax.prototype.getResponseHeader = function (name) {
        if (this._xhr) {
            return this._xhr.getResponseHeader(name)
        } else {
            for (key in this.responseHeaders) {
                if (key.toLowerCase() == name.toLowerCase()) {
                    return this.responseHeaders[key]
                }
            }
            return null
        }
    };
    XMLHttpRequest = hookAjax;
})();

(function() {
    if (window.AjaxBridgeEvent) {
        return
    }

    var AjaxBridgeEvent = {
        _handlers: {},
        addHandler: function (taskName, action, handler) {
            if (typeof taskName === 'string' && typeof handler === 'function') {
                var handlerObject = this._handlers[taskName];
                if (typeof handlerObject !== 'object') {
                    handlerObject = {};
                    this._handlers[taskName] = handlerObject;
                }
                handlerObject[action] = handler
            }
        },
        execHandler: function (taskName, handlerAction, params) {
            var handler = this._handlers[taskName];
            if (typeof handler === 'object') {
                var action = handler[handlerAction];
                if (typeof action === 'function') {
                    action(params)
                }
            }
        },
        removeHandler: function (taskName) {
            if (typeof taskName === 'string') {
                delete this._handlers[taskName];
            }
        },
        removeAllHandler: function () {
            this._handlers = {};
        }
    };
    window.AjaxBridgeEvent = AjaxBridgeEvent;
})();

(function () {
    if (window.AjaxBridge) {
        return
    }
    var AjaxBridge = {
        callNative:(taskName,action,params) => {

            var message = {};
            message.taskName = taskName;
            message.action = action;
            message.params = params;
            var msgJSON = JSON.stringify(message);
            try {
                window.webkit.messageHandlers.PecanProxy_1518040A.postMessage(msgJSON);
            } catch (error) {
                console.log('WKWebView post message');
            }
        },
        callJS: (taskName, action, params) => {
            AjaxBridgeEvent.execHandler(taskName, action, params);
        },
        removeCallback: (taskName) => {
            AjaxBridgeEvent.removeHandler(taskName);
        }
    }
    window.AjaxBridge = AjaxBridge
})()
