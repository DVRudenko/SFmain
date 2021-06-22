public class WorkCurrentUser {
	public User userObj { get; set; }
	public Decimal receivedPoints { get; private set; }
	public Decimal spentPoints { get; private set; }
	public Decimal endPoints { get; private set; }
	public Boolean isWorkcomUser { get; private set; }

	public WorkCurrentUser(Id userId) {
		if (isWorkDotComUser(userId)) {
			this.isWorkcomUser = true;
			this.userObj = ([
					SELECT Id, Name, Points__c, Earned_Points__c, ProfileId, Profile.Name
					FROM User
					WHERE Id =: userId
			]);
			refresh();
		} else {
			this.isWorkcomUser = false;
		}
	}

	private Boolean isWorkDotComUser(Id userId) {
		User user = ([
				SELECT UserPermissionsWorkDotComUserFeature
				FROM User
				WHERE Id =: userId
		]);
		return ( user.UserPermissionsWorkDotComUserFeature != null && user.UserPermissionsWorkDotComUserFeature == true );
	}

	public void refresh() {
		if (this.isWorkcomUser == true) {
			this.userObj = ([
					SELECT Id, Name, Points__c, Earned_Points__c, ProfileId, Profile.Name
					FROM User
					WHERE Id =: userObj.Id
			]);
			updateField(this.userObj);
		}
	}

	private void updateField(User us) {
		List<AggregateResult> spentPointsSum = ([
				SELECT SUM(Prize__r.Cost__c) sumPoints
				FROM UserPrizeAssociation__c
				WHERE User__r.Id =: us.Id
		]);

		receivedPoints = userObj.Earned_Points__c;

		if (spentPointsSum != null && !spentPointsSum.isEmpty() && spentPointsSum.get(0).get('sumPoints') != null) {
			spentPoints = (Decimal)spentPointsSum.get(0).get('sumPoints');
		} else {
			spentPoints = 0;
		}

		endPoints = userObj.Points__c;
	}

	private void validationFields(User us) {
		if (us.Points__c == null || us.Earned_Points__c == null) {
			if (us.Points__c == null) {
				us.Points__c = 0;
			}

			if (us.Earned_Points__c == null) {
				us.Earned_Points__c = 0;
			}
			update us;
		}
	}
}