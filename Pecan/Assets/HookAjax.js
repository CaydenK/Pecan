(function () {
    if (window.realXMLHttpRequest) {
        return
    }

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
        AjaxBridge.callNative(this,arguments)
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
        this.is_abort = true;
        if (this._xhr) {
            this._xhr.abort()
        }
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
        addHandler: function (handlerID, action, handler) {
            if (typeof handlerID === 'string' && typeof handler === 'function') {
                var handlerObject = this._handlers[handlerID];
                if (typeof handlerObject !== 'object') {
                    handlerObject = {};
                    this._handlers[handlerID] = handlerObject;
                }
                handlerObject[action] = handler
            }
        },
        execHandler: function (handlerID, handlerAction, params) {
            var handler = this._handlers[handlerID];
            if (typeof handler === 'object') {
                var action = handler[handlerAction];
                if (typeof action === 'function') {
                    action(params)
                }
            }
        },
        removeHandler: function (handlerID) {
            if (typeof handlerID === 'string') {
                delete this._handlers[handlerID];
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
    var uniqueId = 1;

    var AjaxBridge = {
        callNative: (hookAjax,params) => {
            var callbackID = 'cb_' + (uniqueId++) + '_' + new Date().getTime();

            var message = {};
            message.id = hookAjax.request_id;
            message.data = params;
            message.method = hookAjax.open_arguments[0];
            message.url = hookAjax.open_arguments[1];
            message.headers = hookAjax._headers;

            AjaxBridgeEvent.addHandler(callbackID,'stateChange',(callbackMessage)=>{
                if (!hookAjax.is_abort) {
                    hookAjax.status = callbackMessage.status;
                    hookAjax.responseText = (!!callbackMessage.data) ? callbackMessage.data : "";
                    hookAjax.responseHeaders = callbackMessage.headers;
                    hookAjax.readyState = 4
                } else {
                    hookAjax.readyState = 1
                }
                hookAjax.callbackStateChanged();
            })
            
            var msgJSON = JSON.stringify(message);
            try {
                window.webkit.messageHandlers.PecanProxy_1518040A.postMessage(msgJSON);
            } catch (error) {
                console.log('WKWebView post message');
            }
          

        },
        callJS: (handlerID, action, params) => {
            AjaxBridgeEvent.execHandler(handlerID, action, params);
        },
        removeCallback: (handlerID) => {
            AjaxBridgeEvent.removeHandler(handlerID);
        }
    }
    window.AjaxBridge = AjaxBridge
})()

// (function () {
//     if (window.imy_realxhr) {
//         return
//     }
//     window.imy_realxhr = XMLHttpRequest;
//     var timestamp = new Date().getTime();
//     timestamp = parseInt((timestamp / 1000) % 100000);
//     var global_index = timestamp + 1;
//     var global_map = {};
//     window.imy_realxhr_callback = function (id, message) {
//         var hookAjax = global_map[id];
//         if (hookAjax) {
//             hookAjax.callbackNative(message)
//         }
//         global_map[id] = null
//     };

//     hookAjax.prototype.sendNative = function (data) {
//         this.request_id = global_index;
//         global_map[this.request_id] = this;
//         global_index++;
//         var message = {};
//         message.id = this.request_id;
//         message.data = data;
//         message.method = this.open_arguments[0];
//         message.url = this.open_arguments[1];
//         message.headers = this._headers;
//         window.webkit.messageHandlers.IMYXHR.postMessage(message)
//     };
//     hookAjax.prototype.callbackNative = function (message) {
//         if (!this.is_abort) {
//             this.status = message.status;
//             this.responseText = (!!message.data) ? message.data : "";
//             this.responseHeaders = message.headers;
//             this.readyState = 4
//         } else {
//             this.readyState = 1
//         }
//         this.callbackStateChanged();
//     };

//     window.imy_hookAjax = function () {
//         XMLHttpRequest = hookAjax
//     };
//     window.imy_unhookAjax = function () {
//         XMLHttpRequest = window.imy_realxhr
//     }
// });

