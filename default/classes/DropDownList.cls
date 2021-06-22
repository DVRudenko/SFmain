public abstract class DropDownList {
    private Boolean lockedFlag = false;
    protected abstract Object getValueForDropDownList(Map<String, Object> parameters);

    public Object getValue(Map<String, Object> parameters) {
        if ( ! lockedFlag ) {
            lockedFlag = true;
            return getValueForDropDownList(parameters);
        }
        return null ;
    }
}