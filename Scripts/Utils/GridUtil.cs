using Godot;

namespace Protogame2D.Utils;

public static class GridUtil
{
    public static Vector2 SnapToGrid(Vector2 pos, int gridSize = 16)
    {
        float x = (Mathf.Floor(pos.X / gridSize) + 0.5f) * gridSize;
        float y = (Mathf.Floor(pos.Y / gridSize) + 0.5f) * gridSize;
        return new Vector2(x, y);
    }

    /// <summary>
    /// position 处是否“只有平台”：必须命中至少一个平台，并且所有命中的碰撞体都只能属于 platformLayerMask（不能叠其他 layer）。
    /// </summary>
    public static bool HasOnlyPlatformAt(
        CollisionObject2D self,
        Vector2 position,
        uint platformLayerMask,
        float probeRadius = 4f,
        int maxResults = 16)
    {
        var space = self.GetWorld2D().DirectSpaceState;
        var circle = new CircleShape2D { Radius = probeRadius };

        var query = new PhysicsShapeQueryParameters2D
        {
            Shape = circle,
            Transform = new Transform2D(0, position),
            CollisionMask = uint.MaxValue,     // 查所有层，再在代码里做“纯平台”判断
            CollideWithBodies = true,
            CollideWithAreas = false,
            Exclude = new Godot.Collections.Array<Rid> { self.GetRid() }
        };

        var hits = space.IntersectShape(query, maxResults);
        if (hits.Count == 0)
            return false;

        bool foundPlatform = false;

        foreach (var hit in hits)
        {
            // IntersectShape 的结果里一定会给 rid（无论是普通节点还是 TileMap 的 tile collider）
            if (!hit.ContainsKey("rid"))
                return false; // 理论上不该发生；发生了就保守判失败

            var rid = (Rid)hit["rid"];

            // 因为 query.CollideWithBodies = true 且 Areas = false，这里用 BodyGetCollisionLayer 即可
            uint layers = PhysicsServer2D.BodyGetCollisionLayer(rid);

            bool hasPlatformBit = (layers & platformLayerMask) != 0;
            bool hasAnyNonPlatformBit = (layers & ~platformLayerMask) != 0;

            // 必须包含平台层，并且不能包含任何非平台层（避免 platform layer 与其他 layer 重叠）
            if (!hasPlatformBit || hasAnyNonPlatformBit)
                return false;

            foundPlatform = true;
        }

        return foundPlatform;
    }

}
