var Markov = {
  starts      : [],
  freq        : {},
  order       : 2,

  addText     : function (text) {
    text = text.replace(/\n\s*\n/m, ".");
    var separators = /([.!?:])/
    var fragments = text.split(separators);
    var sentence = "";

    for(var i = 0; i < fragments.length; i++) {
      var fragment = fragments[i];
      if(fragment != "") {
        if(separators.test(fragment)) {
          this.addSentence(sentence, fragment);
          sentence = "";
        }
        else {
          sentence = fragment.trim();
        }
      }
    }
  },

  addSentence   : function(sentence, terminator) {
    var words = sentence.split(" ");
    var buffer = [];

    if(words.length > this.order) {
      words.push(terminator);
      this.starts.push(words.slice(0, this.order));
    }

    for(var i = 0; i < words.length; i++) {
      var word = words[i];
      buffer.push(word);
      if(buffer.length == this.order+1) {
        var key = [ buffer[0], buffer[buffer.length-2] ];
        if(key in this.freq) {
          this.freq[key].push(buffer[buffer.length-1]);
        }
        else {
          this.freq[key] = [ buffer[buffer.length-1] ]
        }
        buffer.shift();
      }
    }
  },

  getText       : function () {
    var startIndex = Math.floor(Math.random() * this.starts.length);
    var res = this.starts[startIndex].slice(0);

    if(res.length == this.order) {
       var nextWord = true;
       while(nextWord != null) {
         var restUp = [ res[res.length-2], res[res.length-1] ];
         try {
           nextWord = this.nextWordFor(restUp);
           if(nextWord != null) {
             res.push(nextWord);
           }
         }
         catch(err) { }
       }

       var newRes = res.slice(0, res.length-2);
       newRes[0] = newRes[0].charAt(0).toUpperCase() + newRes[0].slice(1);

       var sentence = "";
       newRes.forEach(function(word) {
         sentence += word + " ";
       });
       sentence += res[res.length-2] + res[res.length-1];
    }
    else {
      sentence = this.getText();
    }
    return sentence;
  },

  nextWordFor     : function(words) {
    try {
      var options = this.freq[words];
      var randomIndex = Math.floor(Math.random() * options.length);
      return options[randomIndex];
    }
    catch(err) {
      return null;
    }
  }
};

$(function() {
  $('#generate').click(function() {
    $('#out').val(Markov.getText());
  });
});
