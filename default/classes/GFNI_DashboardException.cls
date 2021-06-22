global virtual class GFNI_DashboardException extends Exception {

    public Integer exceptionCode;

    public GFNI_DashboardException(Integer exceptionCode, String exceptionMessage){
        this.exceptionCode = exceptionCode;
        this.setMessage(exceptionMessage);
    }
}