/**
 * Copyright (c) 2013, Peter Vasilevsky
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the RL nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL PETER VASILEVSKY BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

part of routing;

/**
* Router generator
*/

class Router {

    static final Router _router = new Router._internal();

    List<LinkedHashMap> routes;

    factory Router() {
        return _router;
    }

    Router._internal()
    {
        var request = new HttpRequest();
        request.open('POST', '/rl_dart_routing/routes', async: false);
        request.send(null);
        var responce = JSON.decode(request.responseText);
        if (responce['type'] == 'dynamic') {
            this.routes = responce['routes'];
        } else {
            this.routes = JSON.decode(FilesystemHelper.readFile(responce['path']));
        }

    }

    String _generate(String name, params, ReferenceTypes referenceType)
    {
        LinkedHashMap route = this._getRoute(name);
        this._validateVariables(route, params);
        String url = '';
        if (referenceType == ReferenceTypes.WEB_PATH) {
            List<Object> schemes = route['schemes'];
            String scheme = '';
            if (true == schemes.isEmpty) {
                scheme = 'http';
            } else {
                scheme = schemes[0];
            }

            url = scheme + '://' + route['host'];
        }

        url += this._buildUrl(route, params);

        return url;
    }

    LinkedHashMap _getRoute(String name)
    {
        for (var route in this.routes) {
            if (route['name'] == name) {
                return route;
            }
        }
        throw new Exception('No route with name ' + name + ' found');
    }

    void _validateVariables(LinkedHashMap route, LinkedHashMap params)
    {
        params.forEach(((key, value)
        {
            for (var variable in route['variables']) {
                if (variable == key) {
                    if(false == route['requirements'].isEmpty){
                        if (route['requirements'].containsKey(key)) {
                            var regExpPattern = route['requirements'][key];
                            RegExp regExp = new RegExp(regExpPattern);
                            if (!regExp.hasMatch(value.toString())) {
                                throw new Exception('Incorrect value ' + value + ' of ' + key + ' variable.');
                            }
                        }
                    }
                    return;
                }
            }
            throw new Exception('Unknown variable ' + key);
        }));
        for (var variable in route['variables']) {
            if(false == route['defaults'].isEmpty){
                if (!route['defaults'].containsKey(variable)) {
                    if (!params.containsKey(variable)) {
                        throw new Exception('Variable ' + variable + ' is mandatory.');
                    }
                }
            }
        }
    }

    String _buildUrl(LinkedHashMap route, LinkedHashMap params)
    {
        String url = '';
        for (var token in route['tokens']) {
            if (token[0] == 'text') {
                url += token[1];
            } else if (token[0] == 'variable') {
                url += token[1] + params[token[3]].toString();
            } else {
                throw new Exception('Unknown token type');
            }
        }

        return url;
    }
}
