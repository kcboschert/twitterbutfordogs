// Inspiration: https://github.com/tommeagher/heroku_ebooks

var Barker = {
  source           : [],
  dogs             : [],

  getNames         : function () {
    return $.get("assets/barks/dogs.txt", function(dogNames) {
      Barker.dogs = dogNames.split("\n").slice(0, -1);
    });
  },

  getSource        : function () {
    return $.get("assets/barks/text.txt", function(data) {
      Markov.addText(data);
      Barker.source = data.split("\n");
    });
  },

  generateBarks    : function (num) {
    var barkTemplateSource = $("#bark-template").html();
    var barkTemplate = Handlebars.compile(barkTemplateSource);
    var barkStream = $("#barks");
    for(var numBarks = 0; numBarks < 40; numBarks++) {
      var dog = this.getRandomDog();
      var barkContent = {
        fullname: dog.charAt(0).toUpperCase() + dog.slice(1),
        name: dog,
        body: this.getBark(dog)
      };
      var barkHtml = barkTemplate(barkContent);
      barkStream.append(barkHtml);
    }
  },

  getBark          : function (dog) {
    var barkText = Markov.getText();
    if(Math.floor(Math.random() * 5) == 0 && /(in|to|from|for|with|by|our|of|your|around|under|beyond)\s\w+$/.test(barkText)) {
      barkText = barkText.replace(/\s\w+.$/,'');
    }

    if(barkText != null && barkText.length < 40) {
      var rand = Math.floor(Math.random() * 11);
      if(rand < 2) {
        barkText += " " + Markov.getText();
      }
      else if(rand == 3) {
        barkText.toUpperCase();
      }
    }

    if(barkText != null && barkText < 110) {
      if($.inArray(barkText, this.source)) {
        barkText = getBark();
      }
    }
    barkText = barkText.replace(/\:$/,'.');

    var nameRegex = new RegExp("@" + dog);
    while(nameRegex.test(barkText)) {
      barkText = barkText.replace(nameRegex, "@" + this.getRandomDog());
    }
    return barkText;
  },

  getRandomDog     : function () {
    return this.dogs[Math.floor(Math.random() * this.dogs.length)];
  }
};
