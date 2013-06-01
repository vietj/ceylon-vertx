/*
 * Copyright 2013 Julien Viet
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import vietj.vertx.http { HttpServerRequest }

by "Julien Viet"
license "ASL2"
shared void run(){
	
	value vertx = Vertx();
	value server = vertx.createHttpServer();
	
	value http = server.requestHandler(
		(HttpServerRequest req) => req.response.
			contentType("text/html").
			end("<html><body>
			     <h1>Hello from Vert.x with Ceylon!</h1>
			     
			     <h2>Method</h2>
			     <p>``req.method``</p>
			     <h2>Path</h2>               
			     <p>``req.path``</p>
			     <h2>Headers</h2>
			     <p>``req.headers``</p>
			     <h2>Parameters</h2>
			     <p>``req.parameters``</p>
			     <h2>Query parameter</h2>
			     <p>``req.queryParameters``</p>
			     <h2>Form parameters</h2>
			     <p>``req.formParameters else {}``</p>
			                              
			     
			     <form action='/post' method='POST'>
			     <input type='text' name='foo'>
			     <input type='submit'>
			     </form>
			     
			     </body></html>")
	);
	http.listen(8080);
	
    print("Application started");
    process.readLine();
	
	
}


