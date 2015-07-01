cNodePhantomjs = require "./node_phantomjs.js"
nodePhantomjs = new cNodePhantomjs({phantomPath:"c:/phantomjs-2.0.0-windows/bin/phantomjs.exe"})
nodePhantomjs.create ()->
#  nodePhantomjs.stop()
#  nodePhantomjs.open "http://127.0.0.1:3000/votermark/imgphantom/stoly_i_lavki-003.jpg",(status)->
  nodePhantomjs.open "http://lukomskiy.com.ua/votermark/natgrobnii_plitu-020.jpg",{ width: 1, height: 1 },(status)->

    console.log(status)
    nodePhantomjs.evaluate ()->
      document.getElementById('img2').remove();
      Width = document.getElementById('img1').offsetWidth;
      Height = document.getElementById('img1').offsetHeight;
      return  {
        width : Width,
        height : Height
      }
#      return document.getElementById('img1').clientWidth.toString()
    ,(res)->
      console.log(res)
#      nodePhantomjs.paperSize( {
#        width: "#{res.width}px",
#        height: "#{res.height}px",
#        margin: '0px'
#      })
#      console.log(nodePhantomjs.paperSize)
      nodePhantomjs.render "test.jpg",()->
        nodePhantomjs.stop()
