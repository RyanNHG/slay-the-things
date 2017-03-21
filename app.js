var express = require('express'),
    app = express(),
    path = require('path')

app.set('PORT', process.env.PORT || 8000)

app.use(express.static('public'))

app.use('/', (req, res) => {
    res.sendFile(path.join(__dirname + '/index.html'))
})

app.listen(app.get('PORT'), () => 
    console.log(`Running at http://localhost:${app.get('PORT')}`)
)