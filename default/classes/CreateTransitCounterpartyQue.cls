public with sharing class CreateTransitCounterpartyQue implements Queueable {

    private Id opportunityId;

    public CreateTransitCounterpartyQue (Id opportunityId){
        this.opportunityId = opportunityId;
    }

    public void execute(QueueableContext qc) {

        boolean ifSuccessSend = sendToTransit (opportunityId);
        //TODO Вопрос Будем ли отправлять дальше в МЗК если что-то не так с отправкой в транзит????

    }

    public boolean sendToTransit (Id opportunityId){
        TransitRequestData transRequestData;
        /*
        TODO Вызвать метод Юры по получению данных для транзита
         задачи https://petrolplus.atlassian.net/browse/SF-1775
         transRequestData = этим данным
         */
        //TODO логгируем transRequestData
        TransitWebServiceImpl request = new TransitWebServiceImpl();
        try {
            TransitResponseData transResponce = request.storeContData(transRequestData);
            //TODO логгируем transResponce
            if (transResponce != null){
                //TODO анализируем ответ
                return true;
            } else return false;
        } catch (Exception e){
            //TODO логгируем Exception
            return false;
        }

    }

}