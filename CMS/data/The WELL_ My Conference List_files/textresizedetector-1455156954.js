var TRD=TRD||{};
TRD.TextResizeDetector=function(){
var el=null;
var iIntervalDelay=200;
var iInterval=null;
var iCurrSize=-1;
var iBase=-1;
var aListeners=[];
var createControlElement=function(){
el=document.createElement('span');
el.id='textResizeControl';
el.innerHTML='&nbsp;';
el.style.position="absolute";
el.style.left="-9999px";
var elC=document.getElementById(TRD.TextResizeDetector.TARGET_ELEMENT_ID);
if (elC)
elC.insertBefore(el,elC.firstChild);
iBase=iCurrSize=TRD.TextResizeDetector.getSize();
};
function _stopDetector(){
window.clearInterval(iInterval);
iInterval=null;
};
function _startDetector(){
if (!iInterval){
iInterval=window.setInterval('TRD.TextResizeDetector.detect()',iIntervalDelay);
}
};
function _detect(){
var iNewSize=TRD.TextResizeDetector.getSize();
if(iNewSize!==iCurrSize){
for (var i=0;i <aListeners.length;i++){
aListnr=aListeners[i];
var oArgs={ iBase: iBase,iDelta:((iCurrSize!=-1) ? iNewSize - iCurrSize + 'px' : "0px"),iSize:iCurrSize=iNewSize};
if (!aListnr.obj){
aListnr.fn('textSizeChanged',[oArgs]);
}
else{
aListnr.fn.apply(aListnr.obj,['textSizeChanged',[oArgs]]);
}
}
}
return iCurrSize;
};
var onAvailable=function(){
if (!TRD.TextResizeDetector.onAvailableCount_i ){
TRD.TextResizeDetector.onAvailableCount_i=0;
}
if (document.getElementById(TRD.TextResizeDetector.TARGET_ELEMENT_ID)){
TRD.TextResizeDetector.init();
if (TRD.TextResizeDetector.USER_INIT_FUNC){
TRD.TextResizeDetector.USER_INIT_FUNC();
}
TRD.TextResizeDetector.onAvailableCount_i=null;
}
else{
if (TRD.TextResizeDetector.onAvailableCount_i<600){
TRD.TextResizeDetector.onAvailableCount_i++;
setTimeout(onAvailable,200)
}
}
};
setTimeout(onAvailable,500);
return{
init: function(){
createControlElement();
_startDetector();
},
addEventListener:function(fn,obj,bScope){
aListeners[aListeners.length]={
fn: fn,
obj: obj
}
return iBase;
},
detect:function(){
return _detect();
},
getSize:function(){
var iSize;
return el.offsetHeight;
},
stopDetector:function(){
return _stopDetector();
},
startDetector:function(){
return _startDetector();
}
}
}();
TRD.TextResizeDetector.TARGET_ELEMENT_ID='doc';
TRD.TextResizeDetector.USER_INIT_FUNC=null;
TRD.TextResizeDetector.HANDLER=new Array();
TRD.go=function (handler){
TRD.TextResizeDetector.TARGET_ELEMENT_ID='resize_detector';
TRD.TextResizeDetector.HANDLER.push(handler);
TRD.TextResizeDetector.addEventListener(handler, null);
TRD.TextResizeDetector.addEventListener(handler, null);
handler();
};
TRD.resize=function (){
for (var i=0; i < TRD.TextResizeDetector.HANDLER.length; i++){
TRD.TextResizeDetector.HANDLER[i]();
}
}
