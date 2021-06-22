public interface OnboardingReportHtmlGenerator extends HtmlReportGenerator {
    String generateReportHtmlTemplate();
    void addRows(List<Map<String, Object>> records);
}