// Diagnostic client for upstream MCP servers. No substitute server is provided.
import fs from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import {Client} from '../.local/tools/node_modules/@modelcontextprotocol/sdk/dist/esm/client/index.js';
import {StdioClientTransport} from '../.local/tools/node_modules/@modelcontextprotocol/sdk/dist/esm/client/stdio.js';

const spec=JSON.parse(await fs.readFile(process.argv[2], 'utf8'));
const client=new Client({name:'Minecraft tooling diagnostic',version:'0.1.0'});
const transport=new StdioClientTransport({command:spec.command,args:spec.args||[],
  cwd:spec.cwd,env:{...process.env,...spec.env},stderr:'pipe'});
try {
  await client.connect(transport);
  const tools=(await client.listTools()).tools;
  console.log(JSON.stringify({server:spec.name,toolCount:tools.length,tools:tools.map(t=>({name:t.name,inputSchema:t.inputSchema}))}));
  if(spec.startup_wait_ms)await new Promise(r=>setTimeout(r,spec.startup_wait_ms));
  for(const call of spec.calls||[]) {
    const result=await client.callTool({name:call.name,arguments:call.arguments||{}});
    console.log(JSON.stringify({name:call.name,...result}));
    if(result.isError)throw new Error(`${call.name} returned isError`);
    if(call.wait_after_ms)await new Promise(r=>setTimeout(r,call.wait_after_ms));
  }
} finally {await client.close();}
