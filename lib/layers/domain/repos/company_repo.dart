abstract class CompanyRepo {
  const CompanyRepo();

  Future<void> createCompany({
    required int ownerId,
    required String name,
  });

  Future<void> deleteCompany({
    required companyId,
  });

  Future<void> removeUserFromCompany(
      {required int companyId, required int userId});

  Future<void> inviteUserToCompany({
    required int companyId,
    required String email,
    required bool isAdmin,
  });
}
