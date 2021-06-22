global class LongFormController {


    public PageReference init() {
        try {
            String pageName;
            if (Test.isRunningTest()) {
                pageName = 'http://e2efleetcor.force.com/apex/e2eformnl';
            } else {
                pageName = ApexPages.currentPage().getUrl().substringAfter('apex/').toLowerCase();
            }
            String etePageName = returnETEPage(pageName);
            return new PageReference('https://' + ApexPages.currentPage().getHeaders().get('Host') + '/' + etePageName);
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf('e2e redirection exception: ' + e.getMessage()), String.valueOf(e.getStackTraceString()));
            return new PageReference('https://' + ApexPages.currentPage().getHeaders().get('Host'));
        }
    }

    private static String returnETEPage(String pageName) {
        String etePageName;
        switch on pageName {
            when 'e2eform', 'e2eformmob', 'e2eform?country=germany', 'e2eformmob?country=germany' { etePageName = 'etede'; }
            when 'e2eform?country=at', 'e2eformmob?country=at' { etePageName = 'eteat'; }
            when 'e2eformbenl', 'e2eformmobbenl' { etePageName = 'etebenl'; }
            when 'e2eformbefr', 'e2eformmobbefr' { etePageName = 'etebefr'; }
            when 'e2eformch', 'e2eformmobch', 'e2eformch?country=chde', 'e2eformmobch?country=chde' { etePageName = 'etechde'; }
            when 'e2eformch?country=chfr', 'e2eformmobch?country=chfr' { etePageName = 'etechfr'; }
            when 'e2eformhu', 'e2eformmobhu' { etePageName = 'etehu'; }
            when 'e2eformfr', 'e2eformmobfr' { etePageName = 'etefr'; }
            when 'e2eformnl', 'e2eformmobnl' { etePageName = 'etenl'; }
            when 'e2eformpl', 'e2eformmobpl' { etePageName = 'etepl'; }
            when else { etePageName = 'etede'; }
        }
        return etePageName;
    }
}