// Function call and return logger. THe "meat" of this was found unattributed
var Flogger=Flogger||{};
Flogger.enabled=false;
Flogger.lineNumber=0;
Flogger.prefix='';
Flogger.init=function(obj, namespace){
for (var name in obj){
if (Object.prototype.toString.call(obj[name])==='[object Function]'){
obj[name]=Flogger._wrapFunction(obj[name], name, namespace);
}
}
};
Flogger.log=function(){
if (! Flogger.enabled) return;
var myArgs=Flogger._argumentsAsArray(arguments);
var fmt=myArgs.shift();
Flogger._output(fmt, '=', '', myArgs);
};
Flogger.start=function(){
Flogger.enabled=true;
}
Flogger._argumentsAsArray=function(args){
var result=new Array();
if (args){
for (var i=0; i < args.length; i++){
result.push(Flogger._simplify(args[i]));
}
}
return result;
};
Flogger._identInfo=function(arg, fmt, lst){
if (arg&&arg instanceof Object){
var props=[ 'tagName', 'id', 'className', 'name', 'target',
'offsetWidth', 'width', 'maxWidth', 'minWidth',
'selectedIndex', 'selected', 'value' ];
for (var i=0; i < props.length; ++i){
if (props[i] in arg&&arg[props[i]]){
fmt +='[' + props[i] + '="%%s"]';
lst.push(arg[props[i]]);
} else if ('style' in arg&&props[i] in arg.style&&arg.style[props[i]]){
fmt +='[' + props[i] + '="%%s"]';
lst.push(arg.style[props[i]]);
}
}
}
return fmt;
};
Flogger._indent=function(){
Flogger.prefix +=' ';
};
Flogger._logCall=function(name, args){
Flogger._output('(%%O)', '+', name, Flogger._argumentsAsArray(args));
Flogger._indent();
};
Flogger._logReturn=function(name, result){
Flogger._undent();
if (result===undefined){
Flogger._output('', '-', name, []);
} else{
var theargs=Flogger._simplify(result);
Flogger._output(' ->%%O', '-', name, [ theargs ]);
}
};
Flogger._output=function(format, flag, name, theargs){
var vsprintfArgs=[
++Flogger.lineNumber,
Flogger.prefix.length / 2,
Flogger.prefix,
flag,
name
];
var newfmt='%06d [%d]%s%s %s';
var consoleArgs=new Array();
var re=/([^%]|%%%%|%%[a-zA-Z]|.)/ig;
var match;
while ((match=re.exec(format))!==null){
var item=match[0];
newfmt +=item;
if (item==='%%%%'||item.match(/^[^%]$/)){
} else if (item==='%%O'){
newfmt=newfmt.replace(/%%O$/, '');
for (var i=0; i < theargs.length; ++i){
newfmt +=(i===0) ? '%%o' : ',%%o';
var arg=theargs[i];
consoleArgs.push(arg);
newfmt=Flogger._identInfo(arg, newfmt, consoleArgs);
}
} else if (theargs.length===0&&item.match(/^%/)){
var lastItemRE=new RegExp(item + '$');
newfmt=newfmt.replace(lastItemRE, '%' + item);
} else if (item==='%'){
vsprintfArgs.push(theargs.shift());
} else if (theargs.length!==0){
var arg=theargs.shift();
consoleArgs.push(arg);
newfmt=Flogger._identInfo(arg, newfmt, consoleArgs);
}
}
consoleArgs.unshift(vsprintf(newfmt, vsprintfArgs));
window.console.log.apply(window.console, consoleArgs);
};
Flogger._simplify=function(item){
if (item===null)					return '(null)';
if (item==='')					return '""';
if (item===0)						return 0;
if (item===!! item)				return item ? '<true>' : '<false>';
var itemstr=Object.prototype.toString.call(item);
if (itemstr==='undefined')		return '(undefined)';
if (itemstr==='[object Number]')	return item;
if (itemstr==='[object String]')	return '"' + item + '"';
if (itemstr==='[object Function]'){
if ('name' in item&&item.name){
itemstr='[object Function: ' + item.name + ']';
}
return itemstr;
}
if (itemstr==='[object Array]'){
var result=new Array();
for (var i=0; i < item.length; ++i){
result[i]=Flogger._simplify(item[i]);
}
return result;
}
return item;
};
Flogger._undent=function(){
Flogger.prefix=Flogger.prefix.replace(/^ /, '');
};
Flogger._wrapFunction=function(func, name, namespace){
return function(){
try{
var qualified_name=namespace + name;
Flogger._logCall(qualified_name, arguments);
var result=func.apply(this, arguments);
Flogger._logReturn(qualified_name, result);
return result;
} catch (e){
Flogger._undent();
Flogger.log('Caught exception: %s', e);
throw e;
}
};
};
