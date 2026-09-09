
const fs=require("fs");
const path=require("path");

const BASE_PATH=path.join(__dirname,"../src");
const PROJECT_PATH=path.join(__dirname,"../default.project.json");
const NON_SERVER_NAMES=["servertime"];

function toPosix(p){return p.split(path.sep).join("/");}
function toPascalCase(str){if(str.toLowerCase()==="ui")return "UI";return str.charAt(0).toUpperCase()+str.slice(1);}

function getVirtualPath(filepath){
	const relativePath=path.relative(BASE_PATH,filepath);
	const parts=relativePath.split(path.sep);
	const fullName=path.basename(filepath);
	const filename=fullName.replace(/\.luau$/,"");
	const isServer=/\.server$/i.test(filename)&&!NON_SERVER_NAMES.includes(filename.toLowerCase());
	const isClient=/\.client$/i.test(filename);
	const isInit=/^init(?:\.(server|client))?$/i.test(filename);
	let baseName=filename.replace(/\.server$/i,"").replace(/\.client$/i,"");
	const folderName=parts.length>1?toPascalCase(parts[parts.length-2]):"";
	let name=baseName;
	if(isInit)name=folderName;
	else if(["server","client","utils","types"].includes(baseName.toLowerCase()))name=folderName+toPascalCase(baseName);
	let target="ReplicatedStorage";
	if(isServer)target="ServerScriptService";
	else if(isClient)target="StarterPlayerScripts";
	return{target,folder:parts.slice(0,-1).map(toPascalCase),name,file:toPosix(path.join("src",...parts))};
}

function generate(){
	const tree={
		emitLegacyScripts:false,
		name:"Testing",
		tree:{
			$className:"DataModel",
			ReplicatedStorage:{
				Source:{$className:"Folder"},
				Packages:{$path:"Packages"}
			},
			ServerScriptService:{},
			StarterPlayer:{
				StarterPlayerScripts:{}
			}
		}
	};

	const roots={
		ReplicatedStorage:tree.tree.ReplicatedStorage.Source,
		ServerScriptService:tree.tree.ServerScriptService,
		StarterPlayerScripts:tree.tree.StarterPlayer.StarterPlayerScripts
	};

	function walk(dir){
		if(!fs.existsSync(dir))return;
		for(const entry of fs.readdirSync(dir,{withFileTypes:true})){
			const full=path.join(dir,entry.name);
			if(entry.isDirectory())walk(full);
			else if(entry.isFile()&&entry.name.endsWith(".luau")){
				const{target,folder,name,file}=getVirtualPath(full);
				const root=roots[target];
				let current=root;
				for(const part of folder){
					if(!current[part])current[part]={$className:"Folder"};
					current=current[part];
				}
				current[name]={$path:file};
			}
		}
	}

	walk(BASE_PATH);
	fs.writeFileSync(PROJECT_PATH,JSON.stringify(tree,null,2));
	console.log(`🔄 default.project.json atualizado às ${new Date().toLocaleTimeString()}`);
}

generate();

console.log("👀 Observando src...");

let timer;
function update(){
	clearTimeout(timer);
	timer=setTimeout(generate,100);
}

fs.watch(BASE_PATH,{recursive:true},(eventType,filename)=>{
	if(filename&&filename.endsWith(".luau"))update();
});
