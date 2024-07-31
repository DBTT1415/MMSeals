trigger AccountTrig on Account (before delete) {

    AccountTriggerHandler1.delAccount();
}