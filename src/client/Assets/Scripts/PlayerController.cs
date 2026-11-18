// Phố Xô Bồ — Điều khiển nhân vật trong phố 2.5D (MonoBehaviour mỏng, C2)
// Di chuyển isometric theo camera (không hardcode góc 30°/45° — tính từ
// Camera.main để đổi góc camera vẫn đi đúng hướng màn hình), chạm tay để
// đi tới điểm chạm / tương tác hotspot gần nhất. Không chứa luật gameplay:
// tương tác hotspot gọi GameManagerBehaviour.ExploreHotspot (Exploration.cs).
// Chuyển đổi từ Nadia: point-and-click PC → chạm tay mobile 9:16; hotspot
// to, lấp lánh — KHÔNG rà từng pixel (docs/nadia-reference.md §2).
// CHƯA MỞ/BUILD ĐƯỢC trên VM này (không có Unity).
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

namespace PhoXoBo
{
    /// <summary>Nhân vật đi bộ trong khu slice. Pivot đáy (0.5, 0) theo docs/art-assets.md §0.</summary>
    public class PlayerController : MonoBehaviour
    {
        // PROVISIONAL — tốc độ / tầm tương tác / biên khu slice, chưa chốt; đổi ở đây khi test trên máy thật.
        [SerializeField] private float moveSpeed = 4f;
        [SerializeField] private float interactRange = 2.5f;
        [SerializeField] private float moveBounds = 8f;

        private Vector3 _moveTarget;
        private bool _hasMoveTarget;

        private void Update()
        {
            // Bàn phím / joystick: W A S D / phím mũi tên (Input Manager axes mặc định).
            var h = Input.GetAxisRaw("Horizontal");
            var v = Input.GetAxisRaw("Vertical");
            if (Mathf.Abs(h) > 0.01f || Mathf.Abs(v) > 0.01f)
            {
                _hasMoveTarget = false;
                Move(CameraRelativeDirection(h, v));
            }
            else if (_hasMoveTarget)
            {
                var toTarget = _moveTarget - transform.position;
                toTarget.y = 0f;
                if (toTarget.magnitude < 0.15f)
                {
                    _hasMoveTarget = false;
                }
                else
                {
                    Move(toTarget.normalized);
                }
            }

            // Phím E: tương tác hotspot gần nhất trong tầm.
            if (Input.GetKeyDown(KeyCode.E))
                InteractNearest();

            // Click chuột (test trên Editor / WebGL): chạm hotspot thì tương tác, chạm đất thì đi tới đó.
            if (Input.GetMouseButtonDown(0))
                HandlePointer(Input.mousePosition);
        }

        private void LateUpdate()
        {
            // Touch (mobile): chạm 1 ngón bắt đầu chạm.
            if (Input.touchCount <= 0) return;
            var touch = Input.GetTouch(0);
            if (touch.phase == TouchPhase.Began)
                HandlePointer(touch.position);
        }

        private void HandlePointer(Vector2 screenPos)
        {
            // Không cướp chạm của UI (nút điện thoại, tab...) khi đang bấm lên UI.
            if (EventSystem.current != null && EventSystem.current.IsPointerOverGameObject())
                return;

            var cam = Camera.main;
            if (cam == null) return;
            var ray = cam.ScreenPointToRay(screenPos);

            // Chạm trúng hotspot thì tương tác (ưu tiên hotspot gần nhân vật nhất trong tầm).
            if (Physics.Raycast(ray, out var hit, 100f))
            {
                var hotspot = hit.collider != null ? hit.collider.GetComponent<HotspotView>() : null;
                if (hotspot != null)
                {
                    if (Vector3.Distance(transform.position, hotspot.transform.position) <= interactRange)
                        hotspot.Interact();
                    else
                        SetMoveTarget(hotspot.transform.position);
                    return;
                }
                // Chạm đất (không phải hotspot): đi tới điểm chạm (mặt đất y = 0).
                SetMoveTarget(new Vector3(hit.point.x, 0f, hit.point.z));
            }
            else
            {
                // Ray không trúng gì: chiếu xuống mặt phẳng y = 0 để vẫn đi được.
                var plane = new Plane(Vector3.up, Vector3.zero);
                if (plane.Raycast(ray, out var distance))
                    SetMoveTarget(ray.GetPoint(distance));
            }
        }

        private void SetMoveTarget(Vector3 target)
        {
            target.y = 0f;
            target.x = Mathf.Clamp(target.x, -moveBounds, moveBounds);
            target.z = Mathf.Clamp(target.z, -moveBounds, moveBounds);
            _moveTarget = target;
            _hasMoveTarget = true;
        }

        private void Move(Vector3 direction)
        {
            var next = transform.position + direction * moveSpeed * Time.deltaTime;
            next.x = Mathf.Clamp(next.x, -moveBounds, moveBounds);
            next.z = Mathf.Clamp(next.z, -moveBounds, moveBounds);
            next.y = 0f;
            transform.position = next;
        }

        /// <summary>Hướng di chuyển theo camera: W = lên màn hình, D = sang phải màn hình.</summary>
        private static Vector3 CameraRelativeDirection(float h, float v)
        {
            var cam = Camera.main;
            if (cam == null) return new Vector3(h, 0f, v).normalized;
            var forward = cam.transform.forward;
            forward.y = 0f;
            forward.Normalize();
            var right = cam.transform.right;
            right.y = 0f;
            right.Normalize();
            var dir = right * h + forward * v;
            return dir.sqrMagnitude > 0.01f ? dir.normalized : Vector3.zero;
        }

        /// <summary>Tương tác hotspot gần nhất trong tầm (phím E / nút tương tác trên UI).</summary>
        public bool InteractNearest()
        {
            var nearest = HotspotView.Nearest(transform.position, interactRange);
            if (nearest == null) return false;
            return nearest.Interact();
        }
    }
}
