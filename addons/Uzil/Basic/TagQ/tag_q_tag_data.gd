
var id : String

var scope : String

var attr : String

# -1:排除, 0:可選, 1:必要
var search_type : int = 1

func _to_string () :
	var str := "<"
	
	if self.id.is_empty() : return "<invalid tag>"
	
	match self.search_type :
		-1 :
			str += "-"
		0 :
			str += "+"
		
	if not self.attr.is_empty() :
		str += self.attr+"/"
	
	if not self.scope.is_empty() :
		str += self.scope+":"
	
	str += self.id
	
	str += ">"
	
	return str
