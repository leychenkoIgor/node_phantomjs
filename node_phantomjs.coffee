http=require('http')
socketio=require('socket.io')
child=require('child_process')
path = require("path")
fs = require("fs")
#parsePath = require('parse-filepath')
#indexPage=0
#pages={}
#
#class page
#  constructor :(@uuid,@io)->
#    @_paperSize={}
#  open:(url,callback)->
#    pages[@uuid].callback = callback
#    @io.emit "cmd",{cmd:"open",uuid:@uuid,url:url}
#  render:(patchFile,option,callback)->
#    if typeof option == "function"
#      callback = option
#      option = undefined
#    pages[@uuid].callback = callback
#    @io.emit "cmd",{cmd:"render",uuid:@uuid,patchFile:patchFile,option:option}
#  close:()->
##    console.log(Object.keys(pages).length)
#    @io.emit "cmd",{cmd:"close",uuid:@uuid}
#    setTimeout(()=>
#      delete pages[@uuid]
#    ,1)
#  on:(nameEvent,callback)=>
##    switch nameEvent
##      when "error"
##        @onError = callback
##        @io.emit "cmd",{cmd:"onError",uuid:@uuid}
##      when "onCallback"
##        @onCallback = callback
##        @io.emit "cmd",{cmd:"onCallback",uuid:@uuid}
##      when "onConsoleMessage"
##        @onCallback = callback
##        @io.emit "cmd",{cmd:"onConsoleMessage",uuid:@uuid}#
#      @[nameEvent] = callback
#      @io.emit "cmd",{cmd:nameEvent,uuid:@uuid}
#
#  evaluate:(funck,value,callback)=>
#    if typeof value == "function"
#      callback = value
#      value = undefined
#    pages[@uuid].callback = callback
#    @io.emit "cmd",{cmd:"evaluate",uuid:@uuid,funck:funck.toString(),value:value}
#  paperSize:(obj)->
#    if obj
#      @_paperSize = obj
#      @io.emit "cmd",{cmd:"paperSize",uuid:@uuid,paperSize:obj}
#    @_paperSize

class node_phantomjs
  server = undefined
  cCallback = undefined

  constructor : (@options={}) ->
    @options.phantomPath = "phantomjs" if not @options.phantomPath
    @onError = undefined
    @_paperSize = {}

  create:(callback)->
    @server=http.createServer((req,res)->
        res.writeHead(200,{"Content-Type": "text/html"})
        res.end(fs.readFileSync(path.join(__dirname,'controlpage.html')))
    ).listen(()=>
      @io= socketio(@server)
#      console.log(@server.address().port)
      @spawnPhantom(@server.address().port, (err,phantom)=>
        @io.on('connection', (socket)=>
          socket.on("create",()=>
            @cCallback()
          )
          socket.on("open",(res)=>
            @cCallback(res.status)
          )

          socket.on("render",()=>
            @cCallback()
          )
          socket.on("onCallback",(res)=>
            pages[res.uuid].class.onCallback(res.data)
          )
          socket.on("onConsoleMessage",(res)=>
            pages[res.uuid].class.onConsoleMessage(res.msg,res.lineNum,res.sourceId)
          )
          socket.on("evaluate",(res)=>
            @cCallback(res)
          )
          socket.on("onError",(res)=>
            if res.uuid == 0
              if @onError
                @onError(res)
            else
              if pages[res.uuid].class.onError
                pages[res.uuid].class.onError(res)
          )
          @cCallback = callback
          @io.emit "cmd",{cmd:"create"}

        )
      )
    )
  spawnPhantom:( port,callback )->
    args = []
    args.push(path.join(__dirname,'phantomjs.js'), port)
    phantom = child.spawn(@options.phantomPath,args);

    phantom.stdout.on('data',(data)->
      console.log('phantom stdout: '+data)
    )

    phantom.stderr.on('data',(data)->
      console.log('phantom stderrt: '+data)
    )

    callback(null,phantom)

#  create:(callback)->
#    uuid=(require('node-uuid')).v4()
#    @io.emit "cmd",{cmd:"create",uuid:uuid}
#    pages[uuid]={callback:callback,class : new page(uuid,@io)}
#    return pages[uuid].class

  open:(url,viewportSize,callback)=>
    if typeof viewportSize == "function"
      callback = viewportSize
      viewportSize = undefined
    @cCallback = callback
    @io.emit "cmd",{cmd:"open",url:url,viewportSize:viewportSize}

  paperSize:(obj)=>
    if obj
      @_paperSize = obj
      @io.emit "cmd",{cmd:"paperSize",paperSize:obj}
    @_paperSize

  render:(patchFile,option,callback)->
    if typeof option == "function"
      callback = option
      option = undefined
    @cCallback = callback
    @io.emit "cmd",{cmd:"render",patchFile:patchFile,option:option}

  stop:()->
    @io.emit "cmd",{cmd:"exit"}
    @server.close()

  evaluate:(vFunction,value,callback)=>
    if typeof value == "function"
      callback = value
      value = undefined
    @cCallback = callback
#    console.log(typeof {cmd:"evaluate",vFunction:vFunction,value:value}.vFunction)
    @io.emit "cmd",{cmd:"evaluate",vFunction:vFunction.toString(),value:value}

module.exports = node_phantomjs