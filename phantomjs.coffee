system = require('system')
webpage=require('webpage')
controlpage=webpage.create()

#pages={}

#class cPage
#  constructor :(@uuid)->
#    @page=webpage.create()
#    console.log("create " + @uuid)
##    controlpage.evaluate('function(){window.socket.emit("create",'+JSON.stringify({uuid:@uuid})+');}');
#    @Error = undefined
#    @page.onError = (msg, trace)=>
#      @Error = ({msg:msg,trace:trace})
#  open:(data)->
##    @page.paperSize = data.paperSize if data.paperSize != {}
#    console.log("open " + @uuid + " " + data.url)
#    @page.open(data.url,(status)=>
#      controlpage.evaluate((obj)->
#        window.socket.emit("open",obj);
#      ,{uuid:@uuid,status:status})
#    )
#  render:(data)->
##    @page.paperSize = data.paperSize if data.paperSize != {}
#    console.log("render " + @uuid)
#    @page.render(data.patchFile,data.option)
#    controlpage.evaluate('function(){window.socket.emit("render",'+JSON.stringify({uuid:@uuid})+');}');
#  close:()->
#    console.log("close " + @uuid)
#    @page.close()
##  onError:()->
##    @page.onError = (msg, trace)=>
##      controlpage.evaluate((objError)->
##          window.socket.emit("onError",objError);
##        ,{uuid:@uuid,msg:msg,trace:trace});
#  evaluate:(data)=>
##    controlpage.evaluate('function(){window.socket.emit("evaluate",'+JSON.stringify()+');}');
##    console.log(JSON.stringify @page.paperSize)
#    objReturn = @page.evaluate(data.funck,data.value)
#    controlpage.evaluate((obj)->
#      window.socket.emit("evaluate",obj);
#    ,{uuid:@uuid,return:objReturn,err:@Error});
#    if @Error
#      @Error = undefined
#  onCallback:()->
#    @page.onCallback = (data)=>
#      controlpage.evaluate((obj)->
#          window.socket.emit("onCallback",obj);
#        ,{uuid:@uuid,data:data});
#  onConsoleMessage:()->
#    @page.onConsoleMessage = (msg, lineNum, sourceId)=>
#      controlpage.evaluate((obj)->
#          window.socket.emit("onConsoleMessage",obj);
#        ,{uuid:@uuid,msg:msg, lineNum:lineNum, sourceId:sourceId});


page = undefined
controlpage.onCallback = (data)->

  switch data.cmd
    when "create"
      page = webpage.create()
      controlpage.evaluate(()->
        window.socket.emit("create");
      );
    when "open"
      if data.viewportSize
        page.viewportSize = data.viewportSize;
      page.open(data.url,(status)=>
          controlpage.evaluate((obj)->
            window.socket.emit("open",obj);
          ,{status:status})
        )

    when "render"
      page.render(data.patchFile,data.option)
      controlpage.evaluate(()->
        window.socket.emit("render");
      )

#    when "close"
#      pages[data.uuid].close()
#      delete pages[data.uuid]
#    when "onCallback"
#      pages[data.uuid].onCallback()
#    when "onConsoleMessage"
#      pages[data.uuid].onConsoleMessage()
    when "evaluate"
      value = page.evaluate data.vFunction,data.value
      controlpage.evaluate (obj)->
          window.socket.emit("evaluate",obj);
      ,value

    when "paperSize"
      page.paperSize = data.paperSize
    when "exit"
      phantom.exit()

controlpage.onError = (msg, trace)->
#  controlpage.evaluate('function(){window.socket.emit("onError",'+JSON.stringify({uuid:0,msg:msg,trace:trace})+');}');
  console.log(msg, trace)
#controlpage.onConsoleMessage=(msg)->
#  console.log('console msg:'+msg)


controlpage.open('http://127.0.0.1:'+system.args[1]+'/',(status)->)

