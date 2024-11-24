Class WS
{
    __new(url,Callback:= 0)
    {
        this.Client := WebSocket(url,{message: (self, data) => this.Reponse(JSON.parse(data))})
        this.Callback := Callback
    }

    Send(Method,Params:=Map())
    {
        static id := 1
        this.Client.sendText(
            JSON.stringify(
                Map(
                    "id",++id, 
                    "method",Method,
                    "params",Params
                )
            )
        )
    }

    Reponse(data)
    {
        switch data["method"] "|" data["params"]["reason"]
        {
            case "Inspector.detached" "|" "target_closed":
                Notify.show({
                    BDText: "Event: " data["method"] "`nReason: " data["params"]["reason"],
                    HDText: "Rufaydium WebDriver Event",
                    GenIcon: "Critical"
                })
        }

        if this.Callback
            this.Callback.Call(data)
    }

    static observe := [
        'Page.domContentEventFired',
        'Page.fileChooserOpened',
        'Page.frameAttached',
        'Page.frameDetached',
        'Page.frameNavigated',
        'Page.interstitialHidden',
        'Page.interstitialShown',
        'Page.javascriptDialogClosed',
        'Page.javascriptDialogOpening',
        'Page.lifecycleEvent',
        'Page.loadEventFired',
        'Page.windowOpen',
        'Page.frameClearedScheduledNavigation',
        'Page.frameScheduledNavigation',
        'Page.compilationCacheProduced',
        'Page.downloadProgress',
        'Page.downloadWillBegin',
        'Page.frameRequestedNavigation',
        'Page.frameResized',
        'Page.frameStartedLoading',
        'Page.frameStoppedLoading',
        'Page.navigatedWithinDocument',
        'Page.screencastFrame',
        'Page.screencastVisibilityChanged',
        'Network.dataReceived',
        'Network.eventSourceMessageReceived',
        'Network.loadingFailed',
        'Network.loadingFinished',
        'Network.requestServedFromCache',
        'Network.requestWillBeSent',
        'Network.responseReceived',
        'Network.webSocketClosed',
        'Network.webSocketCreated',
        'Network.webSocketFrameError',
        'Network.webSocketFrameReceived',
        'Network.webSocketFrameSent',
        'Network.webSocketHandshakeResponseReceived',
        'Network.webSocketWillSendHandshakeRequest',
        'Network.requestWillBeSentExtraInfo',
        'Network.resourceChangedPriority',
        'Network.responseReceivedExtraInfo',
        'Network.signedExchangeReceived',
        'Network.requestIntercepted'
      ]
}
