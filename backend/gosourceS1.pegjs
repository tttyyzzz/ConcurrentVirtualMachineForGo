{
  function isInvalid(word) {
    return !["var", "go", "func","true","false","int","float32","bool","if" , "else" , "while" , "return","defer","sync.WaitGroup","sync.Mutex"].includes(word);
  }
}



start = mainBlock
//start = functionReturnStatement
//start = sendToChannel
//start = functionDeclarationInputArguments
mainBlock =  whitespace* blocks:( goWhile/conditionals / whileLoop /  functionDeclaration / goFunctionCall/ firstClassFunction/functionCall /receiveFromChannel /sendToChannel /  assignment/waitgroupandmutexcommands/typeChannelInstantiation  / Block / whitespace+ )*  whitespace*  {
  let result = [];
  for (let block of blocks) {
    if (block !== null && !Array.isArray(block)) {
      result.push(block);
    }
  }
if (result.length > 1)
  return {
tag:"blk",
body:{tag:"seq",stmts:result}
}
return {
tag:"blk",
body:result[0]
}
}


Block = "{" whitespace* blocks:( goWhile/conditionals / whileLoop / functionDeclaration/ goFunctionCall/ firstClassFunction/functionCall /  Block / functionReturnStatement /receiveFromChannel/ sendToChannel / assignment / waitgroupandmutexcommands/typeChannelInstantiation / whitespace+)*  a:whitespace* "}" { // need to check if this work without whitespace
  let result = [];
  for (let block of blocks) {
    if (block !== null && !Array.isArray(block)) {
      result.push(block);
    }
  }
if (result.length !== 1){
  return {
tag:"blk",
body:{tag:"seq",stmts:result},
//len:result.length
} 
}
return {
  tag:"blk",
  body:result[0]
}
}

goFunctionCall
= "go" whitespace+ fc:functionCall{
return {
  tag:"goapp",
  args:fc.args,
  fun:fc.fun
}
}


goWhile = "for" whitespace+ cond:condition whitespace* blk:Block{
return{ 
     tag:"while",
     pred:cond,
     body:blk
}
}

firstClassFunction
  =  identifier:variableName whitespace* ":=" whitespace* "func(" functionInputArguments:functionDeclarationInputArguments whitespace* ")"  whitespace* type:(type/"") whitespace* Block:Block{
      // function body is not defined in this example
      return {
        tag: "fun",
        sym: identifier,
        validSym:isInvalid(identifier),
        //prms:functionInputArguments,
        prms:  functionInputArguments.filter(a => a !== undefined).map(a => a.sym),
        prmtype:  functionInputArguments.filter(a => a !== undefined).map(a => a.type !== undefined ? a.type : "undefined"),
        prmValid:functionInputArguments.filter(a => a !== undefined).map(a=> isInvalid(a.sym)),
        rtntype: (type !== "")? type: "undefined",
        body:Block
      };
    }/identifier:variableName whitespace* ":=" whitespace* "func(" whitespace* ")"  whitespace* type:(type/"") whitespace* Block:Block{
      // function body is not defined in this example
      return {
        tag: "fun",
        sym: identifier,
        validSym:isInvalid(identifier),
        prms:  [],
        prmtype:  [],
        prmValid:[],
        rtntype: (type !== "")? type: "undefined",
        body:Block
      };
    }


functionCall
  = identifier:variableName "(" args:(functionInputArguments) ")" {
      // split the functional arguments
      //const splittedArgs = args.map(arg => arg.trim());

      //const splittedArgs = args.flat(Infinity)

      return {
        tag: "app",
        // args: Array.from(splittedArgs),
        args: args,
        fun: { tag: "nam", sym: identifier,validSym:isInvalid(identifier) }
      };
    }
  / identifier:variableName "(" ")" {
      return {
        tag: "app",
        args: [],
        fun: { tag: "nam", sym: identifier,validSym:isInvalid(identifier) }
      };
    }

functionDeclaration
  = "func" whitespace* identifier:variableName "(" functionInputArguments:functionDeclarationInputArguments whitespace* ")"  whitespace* type:(type/"") whitespace* Block:Block{
      // function body is not defined in this example
      return {
        tag: "fun",
        sym: identifier,
        validSym:isInvalid(identifier),
        //prms:functionInputArguments,
        prms:  functionInputArguments.filter(a => a !== undefined).map(a => a.sym),
        prmtype:  functionInputArguments.filter(a => a !== undefined).map(a => a.type !== undefined ? a.type : "undefined"),
        prmValid:functionInputArguments.filter(a => a !== undefined).map(a=> isInvalid(a.sym)),
        rtntype: (type !== "")? type: "undefined",
        body:Block
      };
    }/"func" whitespace* identifier:variableName "(" whitespace* ")"  whitespace* type:(type/"") whitespace* Block:Block{
      // function body is not defined in this example
      return {
        tag: "fun",
        sym: identifier,
        validSym:isInvalid(identifier),
        prms:  [],
        prmtype:  [],
        prmValid:[],
        rtntype: (type !== "")? type: "undefined",
        body:Block
      };
    }


functionInputArguments
  = args:( whitespace* inputArgument whitespace* ("," whitespace* inputArgument)*){
//return args.flat(Infinity).filter(arg => arg !== ",")
return args.flat(Infinity).filter(arg => arg !== ",")

}

functionReturnStatement = whitespace* "return" whitespace* expr:operatorArimetricInputArgument{
   return {
     "tag":"ret",
     "expr":expr
   }
}

whileLoop = "while" whitespace* "(" whitespace* cond:condition whitespace* ")" whitespace* blk:Block whitespace* {
return {tag:"while", pred:cond, body:blk.body}
} 

conditional = "if" whitespace+ cond:condition whitespace* ass:Block whitespace* {
      return { tag: "cond", pred: cond, cons: ass, alt: { tag: "seq", stmts: [] } };
    }


conditionals
  = "if" whitespace+ cond:condition whitespace+
    ass1:Block whitespace* "else" whitespace+ elsecons:conditionals whitespace* {
      return { tag: "cond", pred: cond, cons: ass1.body, alt: elsecons };
    }
/"if" whitespace+ cond:condition whitespace+
    ass1:Block whitespace* "else" whitespace* ass2:Block whitespace* {
      return { tag: "cond", pred: cond, cons: ass1.body, alt: ass2.body };
    }
  /"if" whitespace+ cond:condition whitespace+ ass:Block whitespace* {
      return { tag: "cond", pred: cond, cons: ass.body, alt: { tag: "seq", stmts: [] } };
    }
   




condition = binaryLogicalOperatorAssignment / conditionValue /    operatorArimetricInputArgument 



binaryLogicalOperatorAssignment = conVal:conditionValue whitespace* binLogOp:binaryLogicalOperator whitespace* cond:condition {
return {"tag":"binop","sym":binLogOp,"frst":conVal,"scnd":cond}
}

conditionValue = a:("true" / "false"){
return {"tag": "lit", "val":a === "true",type:"bool"}
}

assignment
  = typeChannelInstantiation/typedVariableInstantiation /typedVariableDeclarableAssignment / constTypedVariableDeclarableAssignment/typedVariableDefaultDeclaration /constTypedVariableDefaultDeclaration/  variableDeclarableAssignment / variableAssignment

typedVariableInstantiation
 = "var" whitespace+ vN:variableName whitespace+ type:("sync.Mutex" /"sync.WaitGroup") {
      return {
        tag: "initCtrl",
        sym: vN,
        type: type === "sync.Mutex" ? "mutexinit":"waitgroupinit"
      };
    }

typeChannelInstantiation  = "var" whitespace+ vN:variableName whitespace+ "chan" whitespace+ type:("int"/"float32"/"bool"){
       return {tag:"initChannel",type:type,sym:vN} 
}

typedVariableDefaultDeclaration
  = "var" whitespace+ vN:variableName whitespace+ type:(type)* whitespace* {
      return {
        tag: "let",
        sym: vN,
        expr: type === "bool"? {tag:"lit",val:false}:{tag:"lit",val:0},
       a:type
      };
 }


constTypedVariableDefaultDeclaration
  = "const" whitespace+ vN:variableName whitespace+ type:(type)* whitespace* {
      return {
        tag: "const",
        sym: vN,
        expr: type === "bool"? {tag:"lit",val:false}:{tag:"lit",val:0},
       a:type
      };
 }

typedVariableDeclarableAssignment
  = "var" whitespace+ vN:variableName whitespace+ type:(type)* whitespace* "=" whitespace* assignmentValue:(condition/operatorArimetricInputArgument/(binaryArimetricOperatorAssignment)*) whitespace* {
      return {
        tag: "let",
        sym: vN,
        expr: assignmentValue,
        exprtype: assignmentValue.type,
        type:type
      };
    }

constTypedVariableDeclarableAssignment
  = "const" whitespace+ vN:variableName whitespace+ type:(type)* whitespace* "=" whitespace* assignmentValue:(condition/operatorArimetricInputArgument/(binaryArimetricOperatorAssignment)*) whitespace* {
      return {
        tag: "let",
        sym: vN,
        expr: assignmentValue,
        exprtype: assignmentValue.type,
        type:type
      };
    }


variableDeclarableAssignment
  = vN:variableName whitespace* ":=" whitespace* assignmentValue:(condition/operatorArimetricInputArgument/(binaryArimetricOperatorAssignment)*) whitespace*{
  return {
  tag:"let",
  sym:vN,
  expr:assignmentValue
}
}

variableAssignment
  = vN:variableName whitespace* "=" whitespace* assignmentValue:(condition/operatorArimetricInputArgument/(binaryArimetricOperatorAssignment)*) whitespace*{
  return {
  tag:"assmt",
  sym:vN,
  expr:assignmentValue
}
}

//objectAccess = vN:variableName "." fc:functionCall {
 //   return {tag:"objectAccess",
//           nam:vN,
//           fun:fc
//
//          }
          
//}

// some of the waitgroup and mutex functions will be here
waitgroupandmutexcommands = 
"defer" whitespace+ vN:variableName ".Done()"{
  return {tag:"ctrlAccess","sym":vN,type:"waitgroupdone"}
}/vN:variableName ".Wait()"{
  return {tag:"ctrlAccess","sym":vN,type:"waitgroupwait"}
}
/vN:variableName ".Lock()"{
  return {tag:"ctrlAccess","sym":vN,type:"mutexLock"} 
}/vN:variableName ".Unlock()"{
  return {tag:"ctrlAccess","sym":vN,type:"mutexUnlock"} 
}
/vN:variableName ".Add("   num:number   ")"{
  return {tag:"ctrlAccess","sym":vN,type:"waitgroupadd",val:num}}




sendToChannel = vN1:variableName whitespace*  "<-" whitespace* vN2:variableName{
    return{ tag:"sendChannel",
            sym: vN1,
            expr: {tag:"nam",sym:vN2}
         } 
}/ vN1:variableName whitespace* "<-" whitespace* num:number{
    return{ tag:"sendChannel",
            sym: vN1,
            expr: {tag:"lit",val:num}
         } 
}


receiveFromChannel = vN1:variableName  whitespace* ":=" whitespace* "<-" whitespace* vN2:variableName{
    return{ tag:"let",
            sym:vN1,
            expr:{tag:"recvChannel",sym:vN2}
}
}
type
  = "int" / "float32" / "bool" 



// the return type of binaryArimetricOperatorAssignment will be checked in the program
binaryArimetricOperatorAssignment
  =  opIA1:leftArimetricInputArgument whitespace* binop:binaryArimetricOperator whitespace* opIA2:operatorArimetricInputArgument {
      return {
        tag: "binop",
        sym: binop,
        frst: opIA1,
        scnd: opIA2,
        frsttype:opIA1.type,
        scndtype:opIA2.type,
        type:(opIA1.type==="number" && opIA2.type==="number")? "number"
               :(opIA1.type==="float32" && opIA2.type!=="int")? "float32"
               :(opIA2.type==="float32" && opIA1.type!=="int")? "float32"
               :(opIA1.type==="int" && opIA2.type!=="float32")? int
               : (opIA2.type==="int" && opIA1.type!=="float32")? int
               : "undefined" // there is only  3 types in this case, float32, int ,number
      };
    }

leftArimetricInputArgument = inputArgument
  / number


operatorArimetricInputArgument
  = binaryArimetricOperatorAssignment
  / inputArgument
  / number




functionDeclarationInputArguments
  = args:( whitespace* inputArgument whitespace* type whitespace* ("," whitespace* inputArgument whitespace* type whitespace* )*){
    return args.flat(Infinity)
               .filter(arg => arg !== ",")
               .map((arg, index, arr) => {
                 if (typeof arg !== 'string') {
                   return { ...arg, type: arr[index + 1] };
                 }
                 return arg;
               }).filter(arg => typeof arg !== 'string') ;
}

functionDeclarationInput
  = identifier:variableName{
return {tag:"nam",sym:identifier,validSym:isInvalid(identifier)}
}

inputArgument
  = whitespace* identifier:functionCall whitespace* {  // changed here
  return identifier
}/ whitespace* identifier:variableName whitespace* {
return {tag:"nam",sym:identifier,validSym:isInvalid(identifier)}
}
  / identifier:number{
return {tag:"lit",val:identifier,type:"number"}
}

Float = digits:$([0-9]+ '.' [0-9]+) { return parseFloat(digits, 10); }

number = Float/[0-9]+ { return parseInt(text(), 10); }

functionKeyword = "func"

keyword = "if" / "else" / "while" / "func" / "var" / "return" / "true" / "false"


variableName = vN:$([a-zA-Z_][a-zA-Z0-9_]* ) {
return vN;
//return vN.flat().join('');
}

variableCommand = vN:$([a-zA-Z_][a-zA-Z0-9_]*) {
  return vN
  //return vN.flat().join('');
}

binaryLogicalOperator = op:("||" / "&&"){
return op
}

binaryArimetricOperator = "+" / "-" / "*" / "/" / "==" / ">" / "<"/ "<=" / ">="
// Define whitespace characters as space, tab, newline, or carriage return
whitespace
  = ws:[ \t\r\n\u0009] {
return undefined
}

