
const chokidar=require("chokidar");
const {spawn}=require("child_process");
const {generate}=require("./generate");
const path=require("path");

const SRC=path.join(__dirname,"../src");

generate();
console.log("✅ default.project.json generated.");
console.log("👀 Watching src/...");
console.log("🚀 Starting Rojo...");

const rojo=spawn("rojo",["serve"],{
	stdio:"inherit",
	shell:true,
	cwd:path.join(__dirname,"..")
});

let timer=null;

function update(){
	clearTimeout(timer);
	timer=setTimeout(()=>{
		generate();
		console.log("🔄 default.project.json updated.");
	},100);
}

const watcher=chokidar.watch(SRC,{
	ignoreInitial:true,
	persistent:true
});

watcher.on("add",update);
watcher.on("change",update);
watcher.on("unlink",update);
watcher.on("addDir",update);
watcher.on("unlinkDir",update);

function shutdown(){
	console.log("\n🛑 Stopping...");
	watcher.close();
	rojo.kill();
	process.exit();
}

process.on("SIGINT",shutdown);
process.on("SIGTERM",shutdown);
