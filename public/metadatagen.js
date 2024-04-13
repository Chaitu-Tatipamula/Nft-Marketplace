var fs = require('fs');

for (var i = 1; i < 20; i++) {
  var json = {}
  json.name = "Token #" + i;
  json.description = "This is the description for token #" + i;
  json.image = "ipfs://QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn/" + i + ".png";

  fs.writeFileSync('' + i+ ".json", JSON.stringify(json));
}