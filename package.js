Package.describe({
    summary: "Easy access to the Wikipedia API for content retrieval.",
    name: "neopostmodern:wikipedia",
    version: "0.0.1",
    git: "https://github.com/neopostmodern/wikipedia.git"
});

Package.on_use(function(api, where) {
    api.use([
    	  'coffeescript',
        'underscore',
        'http'
    ], ['server']);

    api.add_files([
        'lib/wikipedia.coffee'
    ], ['server']);
});

Package.on_test(function(api) {
    api.use('neopostmodern:wikipedia');
    api.use([
    	  'coffeescript',
        'tinytest',
        'test-helpers',
        'underscore',
        'http'
    ], ['server']);
    api.add_files([
        'lib/wikipedia.coffee',
        'tests/wikipedia_tests.coffee'
    ], ['server']);
});
