// Phố Xô Bồ — Test EditMode cho hệ xã hội (Social.cs, Mục 8).
// Chạy bằng Unity Test Runner (EditMode), KHÔNG chạy được trên VM này (không có Unity).
// API thật đang test: Relationship (Interact, ApplyNeglect, AdvanceStage, BreakUp, IsDeep),
// SocialBook (Add, DeepCount, HasBestFriend, HasSupporter, ApplySupportBonus,
// ApplySoloPenalty, CheckGroupDissolved, Divorce, RecordMarriage, IsMarriedTo),
// GameBalance.NeglectDaysToDropCloseness (= 7, đã chốt),
// GameBalance.SupportedExpBonusPercent (= 20, đã chốt),
// GameBalance.SoloSlowerPercentMin/Max (= 30–50, đã chốt).
//
// Số PROVISIONAL (chưa chốt GDD, lấy đúng comment trong Social.cs — đổi code là test
// phải đổi theo): thân thiết khởi đầu 20; Interact +5/lần; bỏ bê giảm 10 / mỗi 7 ngày;
// ngưỡng HenHo ≥50, DinhHon ≥70, Cuoi ≥80; tối đa 3 quan hệ sâu; supporter cần thân
// thiết ≥50; solo penalty 40% (điểm giữa khoảng 30–50% đã chốt).
// Lưu ý hành vi thật (ghi nhận, chưa phải kiểm chứng kỳ vọng):
// - AdvanceStage KHÔNG kiểm tra Kind và không kiểm tra thứ tự ở bước HenHo: một
//   Spouse cũng đi được HenHo -> DinhHon -> Cuoi nếu đủ thân thiết.
// - Divorce ĐÃ SỬA 18/11 (xem test Divorce_SpouseChuaCuoi_TraFalse): trước đây
//   dùng điều kiện (Kind != Spouse && Stage != Cuoi) nên Spouse chưa cưới vẫn
//   ly hôn được; nay dùng || nên phải vừa là Spouse vừa đang ở Stage Cuoi mới
//   ly hôn được.
using NUnit.Framework;

namespace PhoXoBo.Tests
{
    [TestFixture]
    public class SocialTests
    {
        // Thân thiết khởi đầu 20 (PROVISIONAL); +5 mỗi lần Interact (PROVISIONAL).
        private static Relationship Lover(string id = "ny", int startDay = 0) =>
            new Relationship(id, "Nguoi yeu", RelationshipKind.Lover, startDay);

        // Tương tác lặp tới khi thân thiết đạt mốc (mốc phải chia hết cho 5 tính từ 20:
        // 50, 70, 80 đều đạt được: 20 + 5 * n).
        private static void TangThanThietDen(Relationship r, int mucDich, int ngayBatDau = 1)
        {
            var ngay = ngayBatDau;
            while (r.Closeness < mucDich)
                r.Interact(ngay++);
        }

        // --- Bỏ bê: ngưỡng 7 ngày game (GameBalance.NeglectDaysToDropCloseness, đã chốt) ---
        // Mức giảm 10 / mỗi 7 ngày là PROVISIONAL.

        [Test]
        public void BoBe_ChuaDu7Ngay_Tra0VaKhongGiamThanThiet()
        {
            var rel = Lover(startDay: 0); // thân thiết khởi đầu 20, gặp lần cuối ngày 0
            Assert.AreEqual(0, rel.ApplyNeglect(6)); // 6 ngày < 7 -> trả 0
            Assert.AreEqual(20, rel.Closeness, "Chưa đủ 7 ngày thì thân thiết không giảm");
            // Tương tác lại thì đồng hồ bỏ bê chạy lại từ đầu.
            rel.Interact(10); // thân thiết 20 -> 25, gặp lần cuối ngày 10
            Assert.AreEqual(0, rel.ApplyNeglect(16)); // 16 - 10 = 6 ngày < 7 -> trả 0
            Assert.AreEqual(25, rel.Closeness);
        }

        [Test]
        public void BoBe_Du7Ngay_Giam10()
        {
            var rel = Lover(startDay: 0);
            Assert.AreEqual(10, rel.ApplyNeglect(7)); // steps = 7 / 7 = 1 -> giảm 1 * 10
            Assert.AreEqual(10, rel.Closeness); // 20 - 10
        }

        [Test]
        public void BoBe_14Ngay_Giam20()
        {
            var rel = Lover(startDay: 0);
            Assert.AreEqual(20, rel.ApplyNeglect(14)); // steps = 14 / 7 = 2 -> giảm 2 * 10
            Assert.AreEqual(0, rel.Closeness); // 20 - 20
        }

        [Test]
        public void BoBe_21Ngay_ThanThietKepKhongDuoi0()
        {
            var rel = Lover(startDay: 0);
            // steps = 21 / 7 = 3 -> drop = 30, nhưng thân thiết chỉ có 20 nên kẹp về 0.
            // Giá trị trả về vẫn là 30 (mức giảm danh nghĩa), không phải 20 (mức giảm thật).
            Assert.AreEqual(30, rel.ApplyNeglect(21));
            Assert.AreEqual(0, rel.Closeness, "Thân thiết kẹp không dưới 0");
        }

        // --- Interact: +5 thân thiết/lần (PROVISIONAL), cập nhật ngày gặp lần cuối ---

        [Test]
        public void Interact_TangThanThiet5VaCapNhatNgay()
        {
            var rel = Lover(startDay: 0);
            rel.Interact(3);
            Assert.AreEqual(25, rel.Closeness); // 20 + 5
            Assert.AreEqual(3, rel.LastInteractionGameDay);
            rel.Interact(5);
            Assert.AreEqual(30, rel.Closeness); // 25 + 5
            Assert.AreEqual(5, rel.LastInteractionGameDay);
        }

        [Test]
        public void Interact_ThanThietKepKhongQua100()
        {
            var rel = Lover(startDay: 0);
            rel.Interact(1, 90); // 20 + 90 = 110 -> kẹp 100
            Assert.AreEqual(100, rel.Closeness, "Thân thiết kẹp không quá 100");
            rel.Interact(2); // đã 100 thì Interact nữa vẫn 100
            Assert.AreEqual(100, rel.Closeness);
        }

        // --- AdvanceStage: HenHo ≥50, DinhHon đang HenHo + ≥70, Cuoi đang DinhHon + ≥80 ---
        // Ngưỡng là PROVISIONAL. AdvanceStage(HenHo) không kiểm tra Stage hiện tại.

        [Test]
        public void AdvanceStage_HenHo_Duoi50False_Tai50True()
        {
            var rel = Lover();
            Assert.IsFalse(rel.AdvanceStage(RelationshipStage.HenHo), "Thân thiết 20 < 50");
            Assert.AreEqual(RelationshipStage.QuenBiet, rel.Stage, "Thất bại thì Stage không đổi");
            TangThanThietDen(rel, 50); // 20 + 5 * 6 = 50
            Assert.AreEqual(50, rel.Closeness);
            Assert.IsTrue(rel.AdvanceStage(RelationshipStage.HenHo), "Đúng ngưỡng 50 thì được hẹn hò");
            Assert.AreEqual(RelationshipStage.HenHo, rel.Stage);
        }

        [Test]
        public void AdvanceStage_DinhHon_SaiThuTuFalse_DungThuTuTrue()
        {
            var rel = Lover();
            TangThanThietDen(rel, 70); // 20 + 5 * 10 = 70, đủ ngưỡng nhưng sai thứ tự
            Assert.IsFalse(rel.AdvanceStage(RelationshipStage.DinhHon),
                "Chưa HenHo thì không đính hôn được dù thân thiết 70 >= 70");
            Assert.AreEqual(RelationshipStage.QuenBiet, rel.Stage);
            Assert.IsTrue(rel.AdvanceStage(RelationshipStage.HenHo));
            Assert.IsTrue(rel.AdvanceStage(RelationshipStage.DinhHon),
                "Đang HenHo + thân thiết 70 thì đính hôn được");
            Assert.AreEqual(RelationshipStage.DinhHon, rel.Stage);
        }

        [Test]
        public void AdvanceStage_Cuoi_Duoi80False_Tai80True()
        {
            var rel = Lover();
            TangThanThietDen(rel, 70);
            Assert.IsTrue(rel.AdvanceStage(RelationshipStage.HenHo));
            Assert.IsTrue(rel.AdvanceStage(RelationshipStage.DinhHon));
            Assert.IsFalse(rel.AdvanceStage(RelationshipStage.Cuoi),
                "Đang DinhHon nhưng thân thiết 70 < 80 thì chưa cưới được");
            Assert.AreEqual(RelationshipStage.DinhHon, rel.Stage, "Thất bại thì Stage không đổi");
            TangThanThietDen(rel, 80); // 70 + 5 * 2 = 80
            Assert.IsTrue(rel.AdvanceStage(RelationshipStage.Cuoi), "Đang DinhHon + thân thiết 80 thì cưới được");
            Assert.AreEqual(RelationshipStage.Cuoi, rel.Stage);
        }

        // --- SocialBook: tối đa 3 quan hệ sâu (PROVISIONAL), chỉ 1 BestFriend ---

        [Test]
        public void SocialBook_Them3QuanHeSau_DuocThemThu4False()
        {
            var book = new SocialBook();
            Assert.IsTrue(book.Add(new Relationship("ny", "Nguoi yeu", RelationshipKind.Lover, 0)));
            Assert.IsTrue(book.Add(new Relationship("me", "Me", RelationshipKind.Parent, 0)));
            Assert.IsTrue(book.Add(new Relationship("con", "Con", RelationshipKind.Child, 0)));
            Assert.AreEqual(3, book.DeepCount); // Lover + Parent + Child đều là quan hệ sâu
            Assert.IsFalse(book.Add(new Relationship("bt", "Ban than", RelationshipKind.BestFriend, 0)),
                "Đã đủ 3 quan hệ sâu thì thêm quan hệ sâu thứ 4 trả false");
            Assert.AreEqual(3, book.DeepCount);
        }

        [Test]
        public void SocialBook_Chi1BestFriend()
        {
            var book = new SocialBook();
            Assert.IsTrue(book.Add(new Relationship("bt1", "Ban than 1", RelationshipKind.BestFriend, 0)));
            Assert.IsTrue(book.HasBestFriend);
            Assert.IsFalse(book.Add(new Relationship("bt2", "Ban than 2", RelationshipKind.BestFriend, 0)),
                "Đã có bạn thân thì thêm bạn thân thứ 2 trả false (DeepCount mới 1 nên không phải do giới hạn 3)");
            Assert.AreEqual(1, book.DeepCount);
        }

        [Test]
        public void SocialBook_TrungPersonId_TraFalse()
        {
            var book = new SocialBook();
            Assert.IsTrue(book.Add(Lover("ny")));
            Assert.IsFalse(book.Add(new Relationship("ny", "Nguoi khac", RelationshipKind.Parent, 0)),
                "Trùng PersonId thì trả false dù Kind khác");
            Assert.AreEqual(1, book.DeepCount);
        }

        [Test]
        public void SocialBook_FriendGroup_KhongTinhVaoGioiHan3()
        {
            // FriendGroup không phải quan hệ sâu (IsDeep false) nên không tính vào giới hạn 3.
            var book = new SocialBook();
            Assert.IsTrue(book.Add(new Relationship("ny", "Nguoi yeu", RelationshipKind.Lover, 0)));
            Assert.IsTrue(book.Add(new Relationship("me", "Me", RelationshipKind.Parent, 0)));
            Assert.IsTrue(book.Add(new Relationship("con", "Con", RelationshipKind.Child, 0)));
            Assert.IsTrue(book.Add(new Relationship("nhom", "Hoi ban", RelationshipKind.FriendGroup, 0)),
                "Đã đủ 3 quan hệ sâu nhưng FriendGroup vẫn thêm được");
            Assert.AreEqual(3, book.DeepCount, "FriendGroup không làm DeepCount tăng");
            Assert.IsFalse(book.Add(new Relationship("bt", "Ban than", RelationshipKind.BestFriend, 0)),
                "Sau khi thêm nhóm, quan hệ sâu thứ 4 vẫn bị chặn");
        }

        // --- HasSupporter + EXP: supporter thân thiết ≥50 (PROVISIONAL), +20% EXP (đã chốt) ---
        // Solo penalty 40% là PROVISIONAL, nằm trong khoảng 30–50% đã chốt
        // (GameBalance.SoloSlowerPercentMin/Max).

        [Test]
        public void CoSupporter_ApplySupportBonus_100Thanh120()
        {
            var book = new SocialBook();
            var rel = Lover();
            Assert.IsTrue(book.Add(rel));
            Assert.IsFalse(book.HasSupporter, "Thân thiết 20 < 50 nên chưa có supporter");
            TangThanThietDen(rel, 50); // 20 + 5 * 6 = 50, đúng ngưỡng supporter
            Assert.IsTrue(book.HasSupporter);
            Assert.AreEqual(120, book.ApplySupportBonus(100)); // 100 * (100 + 20) / 100
            Assert.AreEqual(100, book.ApplySoloPenalty(100), "Có supporter thì không chịu solo penalty");
        }

        [Test]
        public void KhongSupporter_BonusGiuNguyen_Penalty100Thanh60()
        {
            var book = new SocialBook();
            Assert.IsTrue(book.Add(Lover())); // thân thiết 20 < 50 -> không supporter
            Assert.IsFalse(book.HasSupporter);
            Assert.AreEqual(100, book.ApplySupportBonus(100), "Không supporter thì EXP giữ nguyên");
            // Solo penalty PROVISIONAL 40%: 100 * (100 - 40) / 100 = 60.
            Assert.AreEqual(60, book.ApplySoloPenalty(100));
        }

        // --- CheckGroupDissolved: nhóm 7 ngày không họp thì tan (PROVISIONAL, lấy cùng
        // ngưỡng bỏ bê 7 ngày đã chốt); quan hệ không phải nhóm trả false ---

        [Test]
        public void CheckGroupDissolved_7NgayKhongHop_ThiTan()
        {
            var book = new SocialBook();
            var group = new Relationship("nhom", "Hoi ban", RelationshipKind.FriendGroup, 0);
            Assert.IsTrue(book.CheckGroupDissolved(group, 7), "7 ngày không họp -> nhóm tan");
            Assert.IsFalse(book.CheckGroupDissolved(group, 6), "6 ngày không họp -> nhóm chưa tan");
        }

        [Test]
        public void CheckGroupDissolved_KhongPhaiNhom_TraFalse()
        {
            var book = new SocialBook();
            var rel = Lover(startDay: 0);
            Assert.IsFalse(book.CheckGroupDissolved(rel, 30),
                "Người yêu bỏ bê 30 ngày cũng không 'tan nhóm' vì không phải FriendGroup");
        }

        // --- Divorce: ly hôn Spouse đang ở Stage Cuoi ---

        [Test]
        public void Divorce_SpouseDangCuoi_TraTrue()
        {
            var book = new SocialBook();
            var spouse = new Relationship("vo", "Vo", RelationshipKind.Spouse, 0);
            Assert.IsTrue(book.Add(spouse));
            TangThanThietDen(spouse, 80); // 20 + 5 * 12 = 80
            Assert.IsTrue(spouse.AdvanceStage(RelationshipStage.HenHo));
            Assert.IsTrue(spouse.AdvanceStage(RelationshipStage.DinhHon));
            Assert.IsTrue(spouse.AdvanceStage(RelationshipStage.Cuoi));
            book.RecordMarriage("vo");
            Assert.IsTrue(book.IsMarriedTo("vo"));

            Assert.IsTrue(book.Divorce("vo"), "Ly hôn Spouse đang ở Stage Cuoi");
            Assert.AreEqual(RelationshipStage.TanRa, spouse.Stage);
            Assert.AreEqual(0, spouse.Closeness);
            Assert.IsFalse(book.IsMarriedTo("vo"), "Ly hôn xong thì không còn tính là đã cưới");
            Assert.IsNotNull(book.Get("vo"), "Dòng quan hệ vẫn giữ lại để tính lịch sử, không bị xóa");
        }

        [Test]
        public void Divorce_NguoiKhongPhaiSpouseVaIdLa_TraFalse()
        {
            var book = new SocialBook();
            Assert.IsTrue(book.Add(Lover("ny"))); // Lover, Stage QuenBiet
            Assert.IsFalse(book.Divorce("ny"),
                "Người yêu (không phải Spouse, chưa Cuoi) thì ly hôn trả false");
            Assert.IsFalse(book.Divorce("khong-ton-tai"), "Id không tồn tại thì ly hôn trả false");
            Assert.AreEqual(RelationshipStage.QuenBiet, book.Get("ny")!.Stage,
                "Ly hôn thất bại thì Stage không đổi");
        }

        [Test]
        public void Divorce_SpouseChuaCuoi_TraFalse()
        {
            // ĐÃ SỬA CODE 18/11: Divorce trước đây dùng (Kind != Spouse && Stage != Cuoi)
            // nên Spouse chưa cưới vẫn ly hôn được (bug); nay dùng || nên phải vừa là
            // Spouse vừa đang ở Stage Cuoi mới ly hôn được.
            var book = new SocialBook();
            var spouse = new Relationship("vo", "Vo", RelationshipKind.Spouse, 0);
            Assert.IsTrue(book.Add(spouse));
            Assert.AreEqual(RelationshipStage.QuenBiet, spouse.Stage, "Spouse này chưa hề cưới");
            Assert.IsFalse(book.Divorce("vo"), "Spouse chưa cưới thì ly hôn trả false");
            Assert.AreEqual(RelationshipStage.QuenBiet, spouse.Stage, "Ly hôn thất bại thì Stage không đổi");
            Assert.AreEqual(20, spouse.Closeness, "Ly hôn thất bại thì thân thiết không đổi");
        }

        [Test]
        public void Divorce_LoverDangCuoi_TraFalse()
        {
            // Lover lên được Stage Cuoi (AdvanceStage không kiểm tra Kind) nhưng không
            // phải Spouse nên vẫn không ly hôn được.
            var book = new SocialBook();
            var lover = Lover("ny");
            Assert.IsTrue(book.Add(lover));
            TangThanThietDen(lover, 80);
            Assert.IsTrue(lover.AdvanceStage(RelationshipStage.HenHo));
            Assert.IsTrue(lover.AdvanceStage(RelationshipStage.DinhHon));
            Assert.IsTrue(lover.AdvanceStage(RelationshipStage.Cuoi));
            Assert.IsFalse(book.Divorce("ny"), "Lover ở Stage Cuoi nhưng không phải Spouse thì ly hôn trả false");
            Assert.AreEqual(RelationshipStage.Cuoi, lover.Stage, "Ly hôn thất bại thì Stage không đổi");
        }

        // --- BreakUp: Stage TanRa, Closeness 0, không còn tính là quan hệ sâu ---

        [Test]
        public void BreakUp_StageTanRaThanThiet0VaKhongConSau()
        {
            var book = new SocialBook();
            var rel = Lover();
            Assert.IsTrue(book.Add(rel));
            TangThanThietDen(rel, 50); // từng là supporter (thân thiết 50)
            Assert.AreEqual(1, book.DeepCount);
            Assert.IsTrue(book.HasSupporter);
            rel.BreakUp();
            Assert.AreEqual(RelationshipStage.TanRa, rel.Stage);
            Assert.AreEqual(0, rel.Closeness);
            Assert.IsFalse(rel.IsDeep, "TanRa thì không còn là quan hệ sâu");
            Assert.AreEqual(0, book.DeepCount, "DeepCount giảm sau khi chia tay");
            Assert.IsFalse(book.HasSupporter, "Chia tay rồi thì không còn supporter");
        }
    }
}
