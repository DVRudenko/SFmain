/**
 * Created by Andrei.Moiseev on 06.04.2018.
 */

public interface WorkcomBadgeReceivedProcessorInterface {
    void executeAfterInsert(List<WorkBadge> workBadgeList);
    void executeBeforeInsert(List<WorkBadge> workBadgeList);
}