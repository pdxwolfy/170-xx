// Copyright (C) The WELL, 1996-2014
var W=W||{};
W.RELOAD_INTERVAL_IN_MINUTES=5;
W.AllowClicks=true;
W.AllowReload=true;
W.shortcutFocused=false;
W.focusField=function(me){
if (me.className==='unfilled'&&me.value==='shortcut'){
me.value='';
}
me.className='active';
W.shortcutFocused=true;
};
W.shortcutPrevValue='';
W.unfillShortcut=function(me){
var shortcut=document.getElementById('Shortcut');
if (W.shortcutPrevValue===''&&shortcut.value==='shortcut'){
shortcut.value='';
}
W.shortcutPrevValue=shortcut.value;
}
W.blurField=function(me){
W.shortcutFocused=false;
if (me.value===''){
me.className='unfilled';
me.value='shortcut';
} else{
me.className='filled';
}
};
W.AddEvent=function(elm, evType, fn){
if (elm.addEventListener){
elm.addEventListener(evType, fn, true);
} else if (elm.attachEvent){
elm.attachEvent('on' + evType, fn);
} else{
elm['on' + evType]=fn;
}
};
W.HiddenPostTop=function(huge, howbig, viewnow, first500){
viewnow='<a href="' + viewnow + '">';
if (huge){
document.write(howbig + "<br>" + viewnow + first500 + "<\/a>");
} else{
document.write(viewnow + howbig + "<\/a><br>");
}
};
W.HiddenPostBottom=function(huge, viewall){
if (huge){
document.write("<div class='Centered'>" + viewall + "<\/div>");
}
};
W.CloseThisWindow=function(){
document.write('<div class="CloseWindow">');
if (history.length > 1&&navigator.userAgent.toLowerCase().match(/safari\//)){
document.write('Close this window when done');
} else{
var clicker='window.opener=this; window.close();';
document.write('<a href="#" onclick="' + clicker + '"'
+ ' title="Close this window when done to return to your '
+ 'main conferencing window">'
+ 'Close this window<\/a>');
}
document.write('<\/div>');
};
W.ActionButton=function(url, confirm, text){
var action="return confirm('" + confirm + "');";
document.write('<a href="' + url + '" onclick="' + action
+ '" class="TextButton">' + text + '<\/a>');
};
W.RevealAdvancedSearchOptions=function(reveal){
W.Reveal('SearchAdvanced1', reveal, 'inline');
W.Reveal('SearchAdvanced2', reveal, 'inline');
W.Reveal('SearchAdvanced3', reveal, 'inline');
W.Reveal('SearchAdvanced4', reveal, 'inline');
W.Reveal('SearchAdvanced5', reveal, 'table-row');
W.Reveal('SearchAdvanced6', reveal, 'table-row');
W.Reveal('SearchAdvanced7', reveal, 'table-row');
W.Reveal('SearchAdvanced8', reveal, 'table-row');
W.Reveal('SearchAdvanced9', reveal, 'inline');
var link=document.getElementById('ShowAdvancedOptions');
link.innerHTML='<a href="#" id="AdvancedOptionsLink" '
+ 'onclick="W.RevealAdvancedSearchOptions(X1); return false;">'
+ 'X2 advanced options<\/a>';
link.innerHTML=link.innerHTML.replace(/X1/, reveal ? 'false' : 'true')
.replace(/X2/, reveal ? 'Hide' : 'Show');
var advanced=document.getElementById('advanced');
Flogger.log("advanced=%%o value=%%o reveal=%%o",
advanced, advanced.value, reveal);
var showAdvancedOptionsNote=! reveal&&(advanced.value==='yes');
W.Reveal('AdvancedOptionsHidden', showAdvancedOptionsNote, 'table-row');
if (reveal){
advanced.value='yes';
}
};
W.LinkedTopicsNotice=function(show){
document.write("<p><a href='#' onclick=" + show
+ ">This topic is linked<\/a></p>");
};
W.settingsHelpId=0;
W.MakeHelp=function(text, isMobile){
if (isMobile){
++W.settingsHelpId;
document.write(
"<div class='Hidden SettingsItemHelpMobile'>"
+	"<a href='javascript:W.ShowMobileTooltip(" + W.settingsHelpId
+	");'"
+	" id='SettingsHelpButton" + W.settingsHelpId + "'>?</a>"
+	"<div class='Hidden SettingsItemTooltip' id='SettingsTooltip"
+	W.settingsHelpId + "'>"
+	text
+	"</div></div>"
);
} else{
document.write(
"<div class='SettingsItemHelp'>"
+	"<a href='#'>?"
+	"<div class='Hidden SettingsItemTooltip'>"
+	text
+	"</div></a></div>"
);
}
};
W.modifierMask=0;
if (typeof(Event)!=='undefined'&&typeof(Event.ALT_MASK)!=='undefined'){
W.modifierMask=Event.ALT_MASK | Event.CONTROL_MASK | Event.META_MASK;
};
W.HandleKeystroke=function(event){
var evt=event||window.event;
if (W.IgnoreInput(evt)){
return W.NOT_HANDLED;
}
if (typeof(evt.altKey)==='undefined'){
if (evt.modifiers & W.modifierMask!==0){
return W.NOT_HANDLED;
}
} else{
if (evt.altKey||evt.ctrlKey||evt.metaKey){
return W.NOT_HANDLED;
}
}
if (typeof console==='object'){
Flogger.log("evt.keyCode=" + evt.keyCode + " evt.which=" + evt.which);
}
var ch=evt.keyCode||evt.which;
if (! ch){
return W.NOT_HANDLED;
}
var theKey=String.fromCharCode(ch).toUpperCase();
var handler=W.Shortcuts[theKey];
if (handler){
var handled=handler();
if (handled!==W.NOT_HANDLED){
if (evt.stopPropagation){
evt.stopPropagation();
evt.preventDefault();
} else{
evt.cancelBubble=true;
evt.returnValue=false;
}
return handled;
}
}
return W.NOT_HANDLED;
};
W.NOT_HANDLED=0;
W.UNLOAD_THIS_PAGE=1;
W.NO_PAGE_UNLOAD=2;
W.GotKeystroke=false;
W.KeyHandler=function(evt){
if (W.GotKeystroke){
return true;
}
W.GotKeystroke=true;
var result=W.HandleKeystroke(evt);
if (result===W.NO_PAGE_UNLOAD||result===W.NOT_HANDLED){
W.GotKeystroke=false;
}
return result===W.NOT_HANDLED;
};
W.ReadyToHandleShortcuts=false;
W.InitKeyHandler=function(){
W.ReadyToHandleShortcuts=true;
};
W.KBFocus=function(){
if (W.IsMobile){
return;
}
if (! document.hasFocus||document.hasFocus()){
var kbfocus=document.getElementById('KBFocus');
if (kbfocus){
kbfocus.focus();
}
}
if (navigator.userAgent&&! navigator.userAgent.match(/mobile/)){
var clickWrapper=function(){
var allowReload=W.AllowReload;
W.AllowReload=true;
document.getElementById('Wrapper').click();
W.AllowReload=allowReload;
};
window.setTimeout(clickWrapper, 500);
}
};
W.LoadKBShortcuts=function(){
W.AddEvent(document, 'keydown', W.KeyHandler);
W.InitKeyHandler();
};
W.reloadTimeoutId=null;
W.ReloadMyList=function(){
Flogger.log('RELOAD_INTERVAL_IN_MINUTES=%d', W.RELOAD_INTERVAL_IN_MINUTES);
if (W.RELOAD_INTERVAL_IN_MINUTES > 0){
var reload_interval=W.RELOAD_INTERVAL_IN_MINUTES * 60 * 1000;
W.reloadTimeoutId=window.setTimeout('W.Reload();', reload_interval);
}
};
W.RevealElement=function(theElement, reveal, how){
if (typeof(how)==="undefined"){
how='block';
}
if (typeof(reveal)==="undefined"){
reveal=(theElement.style.display!==how);
}
if (document.all&&how==='table-row'){
how='block';
}
theElement.style.display=reveal ? how : 'none';
};
W.Reveal=function(id, reveal, how){
var theElement=document.getElementById(id);
if (theElement){
W.RevealElement(theElement, reveal, how);
}
};
W.SearchDone=function(){
W.Reveal('Searching', false);
W.Reveal('SearchResults', true);
};
W.ChangeSearchType=function(dropdown, changedByUser){
if (! dropdown){
dropdown=document.getElementById('SearchType');
}
var withresults=(document.getElementById('withresults').value==='yes');
var showopts=(changedByUser===true||! withresults);
var value=dropdown[dropdown.selectedIndex].value;
W.Reveal('BasicSearchOptions', value!=='X');
W.Reveal('MemberSearchForm', value==='M');
W.Reveal('TitleSearchForm', value==='T');
W.Reveal('FullTextSearchOptions', value==='X'&&showopts);
W.Reveal('SearchForm', true);
W.Reveal('SearchResultsArea', withresults);
W.Reveal('ReopenSearch', value==='X'&&! showopts);
W.Reveal('CloseSearch', false);
};
W.InitializeSearch=function(){
W.ChangeSearchType();
var advanced=document.getElementById('advanced');
Flogger.log('advanced=%%o', advanced);
W.RevealAdvancedSearchOptions(advanced.value==='yes');
};
W.SetCurrentTab=function(tabId){
var tab=document.getElementById(tabId);
if (tab){
tab.className='SettingsNavCurrent';
}
};
W.ValidateJumpData=function(lastResponse){
var value=document.getElementById("JumpData").value;
if (value===''){
return true;
}
var msg;
var range=value.match(/^(\d+)(?:-(\d*))?$/);
if (range===null){
msg="Jump destination '" + value + "' is not valid";
} else{
var ix1=parseInt(range[1]);
var ix2=range[2] ? parseInt(range[2]) : ix1;
if (ix1 > ix2){
msg="Invalid jump destination: first value > second value";
} else if (ix1 > lastResponse){
msg="This topic doesn't have a response #" + range[1];
} else if (ix2 > lastResponse){
msg="This topic doesn't have a response #" + range[2];
} else{
return true;
}
}
alert(msg);
return false;
};
W.EnableTrace=function(enable){
if (enable&&window.console&&window.console.log&&typeof window.console.log==='function'){
var items={ '': W };
for (var namespace in items){
Flogger.init(items[namespace], namespace);
}
Flogger.start();
}
};
W.DoPlacemark=function(id, url){
var form=document.getElementById(id + '_f');
var checkbox=document.getElementById(id + '_cb');
if (form&&checkbox){
if (! window.is_loaded){
form.reset();
alert('Please wait until window is fully loaded '
+ 'before setting placemarks.');
return;
}
W.ShowWorking();
window.setTimeout(function(){ W.HideWorking(); }, 2500);
form.action=form.action.replace(/&N=./, '') + '&N='
+ (checkbox.checked ? 'A' : 'R');
var req=new XMLHttpRequest();
req.open('GET', form.action, false);
req.send(null);
W.SetPlacemarkTooltip(checkbox);
} else if (form){
alert("Cannot find checkbox " + checkbox);
} else{
alert("Cannot find form " + form);
}
};
W.SetPlacemarkTooltip=function(checkbox, topic){
var title;
if (topic){
title=checkbox.checked
? 'Uncheck to remove this topic from your placemarks'
: 'Check to add this topic to your placemarks';
} else{
title=checkbox.checked
? 'Uncheck to remove this response from your placemarks'
: 'Check to add this response to your placemarks';
}
checkbox.setAttribute('title', title);
};
W.InitPlacemarkTooltip=function(id, topic){
var checkbox=document.getElementById(id + '_cb');
if (checkbox){
W.SetPlacemarkTooltip(checkbox, topic);
}
};
W.CanClick=function(){
if (W.AllowClicks){
W.AllowReload=false;
}
return W.AllowClicks;
};
W.Reload=function(){
Flogger.log("shortcutFocused=%%o, allowReload=%%o", W.shortcutFocused, W.AllowReload);
if (W.shortcutFocused||! W.AllowReload){
W.ReloadMyList();
} else{
W.AllowClicks=false;
setTimeout(function(){
W.reloadTimeoutId=-1;
W.ShowWorking();
var target=document.getElementById('MyListNav');
if (target&&target.href) location.href=target.href;
},
500);
setTimeout(function(){ W.AllowClicks=true; }, 750);
}
};
W.PostponeReload=function(evt){
if (W.reloadTimeoutId===-1){
if (evt.stopPropaagation){
evt.stopPropagation();
evt.preventDefault();
} else{
evt.cancelBubble=true;
evt.returnValue=false;
}
return false;
}
if (W.reloadTimeoutId > 0){
window.clearTimeout(W.reloadTimeoutId);
W.ReloadMyList();
}
return true;
};
W.AddEvent(window, 'click', W.PostponeReload);
W.AddEvent(window, 'keydown', W.PostponeReload);
W.AddEvent(window, 'mousedown', W.PostponeReload);
W.dataEntryTags={
'select': '',
'textarea': ''
};
W.inputTypes={
'file': '',
'password': '',
'text': ''
};
W.IgnoreInput=function(evt){
if (! W.ReadyToHandleShortcuts){
return true;
}
var el=evt.target||evt.srcElement;
var tag=(el&&el.tagName&&el.tagName.toLowerCase())||'';
if (tag==='input'){
return typeof W.inputTypes[el.type.toLowerCase()]==='string';
}
return typeof W.dataEntryTags[tag]==='string';
};
W.Invoke=function(id){
var target=document.getElementById(id);
if (! target){
return false;
}
W.ShowWorking();
if (target.href){
if (target.target){
window.open(target.href, target.target);
W.HideWorking();
} else{
location.href=target.href;
}
} else if (target.click){
target.click();
}
return true;
};
W.HandledAction=function(unload){
return unload ? W.UNLOAD_THIS_PAGE : W.NOT_HANDLED;
};
W.UnloadAction=function(unload){
return unload ? W.NO_PAGE_UNLOAD : W.NOT_HANDLED;
};
W.DoGlobalSeeNew=function(){
return W.HandledAction(W.Invoke('GSN'));
};
W.DoHelp=function(){
return W.UnloadAction(W.Invoke('Help'));
};
W.DoSeeNew=function(){
return W.HandledAction(W.Invoke('SeeNew'));
};
W.DoMyList=function(){
return W.HandledAction(W.Invoke('MyListNav'));
};
W.DoPass=function(){
return W.HandledAction(W.Invoke('Pass'));
};
W.DoNext=function(){
if (W.DoPass()===W.UNLOAD_THIS_PAGE||W.DoSeeNew()===W.UNLOAD_THIS_PAGE||W.DoGlobalSeeNew()===W.UNLOAD_THIS_PAGE||W.DoMyList()===W.UNLOAD_THIS_PAGE){
return W.UNLOAD_THIS_PAGE;
}
return W.NOT_HANDLED;
};
W.DoResponse=function(){
var response=document.getElementById('Response');
if (response){
response.focus();
return W.NO_PAGE_UNLOAD;
}
return W.NOT_HANDLED;
};
W.DoShortcut=function(){
var shortcut=document.getElementById('Shortcut');
if (shortcut){
shortcut.focus();
return W.NO_PAGE_UNLOAD;
}
return W.NOT_HANDLED;
};
W.Shortcuts={
'C' : function(){ return W.UnloadAction(W.Invoke('Confs')); },
'G' : W.DoShortcut,
'H' : W.DoHelp,
'K' : function(){ return W.HandledAction(W.Invoke('KeepNew')); },
'L' : W.DoMyList,
'M' : function(){ return W.UnloadAction(W.Invoke('Placemarks')); },
'N' : W.DoNext,
'P' : W.DoPass,
'R' : W.DoResponse,
'S' : function(){ return W.UnloadAction(W.Invoke('Search')); },
'T' : function(){ return W.HandledAction(W.Invoke('ListTopics')); }
};
W.ChangeSpecifiedConferences=function(me){
var selected=document.getElementById('specified_conferences_listed');
var cflist=document.getElementById('specified_conferences_cflist');
var iAmEmpty=(me.value==='');
selected.checked=! iAmEmpty;
cflist.checked=iAmEmpty;
if (! iAmEmpty){
var listed_topics=document.getElementById('specified_topics_listed');
if (listed_topics.checked){
var all_topics=document.getElementById('specified_topics_all');
all_topics.checked=true;
listed_topics.checked=false;
}
}
};
W.ChangeSpecifiedTopics=function(me){
var selected=document.getElementById('specified_topics_listed');
var all=document.getElementById('specified_topics_all');
var iAmEmpty=(me.value==='');
selected.checked=! iAmEmpty;
all.checked=iAmEmpty;
};
W.ChangeSpecifiedResponses=function(me){
var selected=document.getElementById('specified_responses_listed');
var all=document.getElementById('specified_responses_all');
var iAmEmpty=(me.value==='');
selected.checked=! iAmEmpty;
all.checked=iAmEmpty;
};
W.ChangeSpecifiedTimeframe=function(me){
var which=me.name.match(/^since/) ? 'since' : 'before';
var month=document.getElementById(which + '_month');
var day=document.getElementById(which + '_day');
var year=document.getElementById(which + '_year');
var ndays=document.getElementById(which);
if (me.name===which){
month.selectedIndex=0;
day.selectedIndex=0;
year.selectedIndex=0;
} else{
ndays.value='';
}
};
W.ChangeSpecifiedUsers=function(me){
var selected=document.getElementById('specified_users_listed');
var excluded=document.getElementById('specified_users_excluded');
var all=document.getElementById('specified_users_all');
var iAmEmpty=(me.value==='');
var myradio=(me.name==='users') ? selected : excluded;
var otherradio=(me.name==='users') ? excluded : selected;
var otherid=(me.name==='users') ? 'excluded' : 'users'
var other=document.getElementById('specified_users_' + otherid);
var otherIsEmpty=(other.value==='');
all.checked=iAmEmpty&&otherIsEmpty;
myradio.checked=! iAmEmpty;
otherradio.checked=iAmEmpty&&! otherIsEmpty;
};
W.SearchSubmitted=function(){
var submitted=document.getElementById('submitted');
if (submitted){
submitted.value="submitted";
}
W.Reveal('SearchForm', false);
W.Reveal('ReopenSearch', false);
W.Reveal('CloseSearch', false);
W.Reveal('Searching', true);
W.Reveal('SearchResultsArea', false);
document.getElementById('withresults').value='yes';
};
W.ForgottenChanged=function(me){
if (me.name==='forgotten_topics'){
if (me.checked){
var other=document.getElementById('forgotten_topics_only');
other.checked=false;
}
} else{
if (me.checked){
var other=document.getElementById('forgotten_topics_excluded');
other.checked=false;
}
}
};
W.ReopenSearchForm=function(){
W.Reveal('FullTextSearchOptions', true);
W.Reveal('CloseSearch', true);
W.Reveal('ReopenSearch', false);
var advanced=document.getElementById('advanced');
Flogger.log('advanced=%%o', advanced);
W.RevealAdvancedSearchOptions(advanced.value==="yes");
};
W.CloseSearchForm=function(){
W.Reveal('FullTextSearchOptions', false);
W.Reveal('CloseSearch', false);
W.Reveal('ReopenSearch', true);
};
W.modifiers_in_use=false;
W.CheckModifier=function(event){
var evt=event||window.event;
if (typeof(evt.altKey)==="undefined"){
var mods=Event.ALT_MASK||Event.CTRL_MASK||Event.META_MASK||Event.SHIFT_MASK;
W.modifiers_in_use=(evt.modifiers & mods!==0);
} else{
W.modifiers_in_use=evt.altKey||evt.ctrlKey||evt.metaKey||evt.shiftKey;
}
};
W.AddEvent(window, 'keydown', W.CheckModifier);
W.AddEvent(window, 'keyup', W.CheckModifier);
W.Open=function(me){
if (! W.modifiers_in_use&&me.target!=='_top'&&me.href.match(':')){
window.open(me.href, me.target);
return false;
}
return true;
};
W.ShowWorking=function(){
W.Reveal('Working', true);
var working=document.getElementById('Working');
if (working){
var scrollTop=window.pageYOffset;
if (scrollTop){
working.style.top=scrollTop + 'px';
}
}
};
W.HideWorking=function(){
W.Reveal('Working', false);
};
W.AddEvent(window, 'unload', W.HideWorking);
W.ShowMobileTooltip=function(id){
var tooltip=document.getElementById("SettingsTooltip" + id);
if (tooltip){
var button=document.getElementById("SettingsHelpButton" + id);
if (button){
if (tooltip.style.display==='block'){
tooltip.style.display='none';
button.style.color='#cc0000';
button.style.backgroundColor='white';
} else{
tooltip.style.display='block';
button.style.color='white';
button.style.backgroundColor='#cc0000';
}
}
}
};
W.DoNothing=function(){
};
W.NoResponseRequest=function(elem, url){
var req=new XMLHttpRequest();
req.open('GET', url, false);
req.send(null);
elem.style.color=window.getComputedStyle(elem, null)
.getPropertyValue('background-color');
};
W.GetCookie=function (name, dft){
var value="; " + document.cookie;
var parts=value.split("; " + name + "=");
if (parts.length==2) return parts.pop().split(";").shift();
return dft;
}
W.SetCookie=function (name, value){
document.cookie=name + '=' + value;
}
W.ToolbarHeight=function(){
var wrapper=document.getElementById('MainToolbarWrapper');
var toolbar=document.getElementById('MainToolbar');
var height=Math.max(wrapper.offsetHeight, toolbar.offsetHeight);
Flogger.log('toolbar height=%%o', height);
return height;
}
W.AdjustBodyHeightBottom=function(){
var height=W.ToolbarHeight();
document.getElementById('user-well-com').style.paddingBottom=height
+ 'px';
document.getElementById('Wrapper').style.bottom=height + 'px';
};
W.AdjustBodyHeightTop=function(){
var height=W.ToolbarHeight();
document.getElementById('user-well-com').style.paddingTop=height + 'px';
document.getElementById('Wrapper').style.top=height + 'px';
};
W.ResizeToolbar=function(){
if (W.IsMobile){
return;
}
var toolbarClass=document.getElementById('MainToolbarWrapper').className;
if (toolbarClass.match(/^TBTop/)){
W.AdjustBodyHeightTop();
} else if (toolbarClass.match(/^TBBottom/)){
W.AdjustBodyHeightBottom();
}
};
W.Onload=function(){
W.EnableTrace(true);
window.is_loaded=true;
W.LoadKBShortcuts();
document.getElementById('Shortcut').value='shortcut';
TRD.go(W.ResizeToolbar);
if (W.OnloadLocal){
W.OnloadLocal();
}
W.KBFocus();
}
