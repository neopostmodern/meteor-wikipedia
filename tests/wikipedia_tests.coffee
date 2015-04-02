SAMPLE_PAGE_ID = 39133776

Tinytest.add "wikipedia - Get Summary For Page ID", (test) ->
    summary = Wikipedia.GetSummaryForPageId SAMPLE_PAGE_ID
    console.dir summary
    test.isTrue Match.test summary, String

Tinytest.add "wikipedia - Get Article For Page ID", (test) ->
    summary = Wikipedia.GetArticleForPageId SAMPLE_PAGE_ID
    console.dir summary
    test.isTrue Match.test summary, String