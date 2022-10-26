using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoftwareRenderer : MonoBehaviour
{
    public Texture2D targetTexture;
    public Camera targetCamera;
    public Color clearColor;

    [ContextMenu("Render")]
    public void Render()
    {
        if(targetTexture == null)
        {
            targetTexture = new Texture2D(1920, 1080);
        }
        Clear(clearColor);
        Render(targetCamera);
        targetTexture.Apply();
    }

    private void Update()
    {
        if(Input.GetKeyDown(KeyCode.Space))
        {
            clearColor = Random.ColorHSV();
            Render();
        }
    }

    public void Render(Camera camera)
    {
        var meshFilters = FindObjectsOfType<MeshFilter>();

        var viewMatrix = camera.transform.worldToLocalMatrix;
        var projectionMatrix = Matrix4x4.Perspective(camera.fieldOfView, (float)targetTexture.width / targetTexture.height, camera.nearClipPlane, camera.farClipPlane);


        foreach (var meshFilter in meshFilters)
        {
            var mesh = meshFilter.sharedMesh;
            if (mesh == null)
                continue;
            for(var submesh = 0; submesh < mesh.subMeshCount; ++submesh)
            {
                RenderMesh(mesh, submesh, meshFilter.transform.localToWorldMatrix, viewMatrix, projectionMatrix);
            }
        }
    }

    public void Clear(Color color)
    {
        var pixels = targetTexture.GetPixels();
        for (int i = 0; i < pixels.Length; i++)
        {
            pixels[i] = color;
        }
        targetTexture.SetPixels(pixels);
    }

    public void RenderMesh(Mesh mesh, int subMeshIndex, Matrix4x4 modelMatrix, Matrix4x4 viewMatrix, Matrix4x4 projectionMatrix)
    {
        var mvpMatrix = projectionMatrix * viewMatrix * modelMatrix;

        // Input Assembler Stage
        var vertices = mesh.vertices;
        var indices = mesh.GetIndices(subMeshIndex);
        var triangles = new List<Vector3[]>();


        for (int triangleIndex = 0; triangleIndex < indices.Length/3; ++triangleIndex)
        {
            var triangle = new Vector3[3];
            triangle[0] = vertices[indices[triangleIndex * 3 + 0]];
            triangle[1] = vertices[indices[triangleIndex * 3 + 1]];
            triangle[2] = vertices[indices[triangleIndex * 3 + 2]];
            triangles.Add(triangle);
        }

        foreach(var triangle in triangles)
        {
            for (int vertexIndex = 0; vertexIndex < 3; ++vertexIndex)
            {
                // Vertex Shader
                triangle[vertexIndex] = mvpMatrix.MultiplyPoint(triangle[vertexIndex]);
            }
        }

        // Rasterization Stage

        // Remove Outside Bounds

        triangles.RemoveAll((triangle) =>
        {
            bool insideBounds = false;
            foreach (var vertex in triangle)
            {
                if (Mathf.Abs(vertex.x) < 1 ||
                    Mathf.Abs(vertex.y) < 1 ||
                    Mathf.Abs(vertex.z) < 1)
                {
                    insideBounds = true;
                }
            }
            return !insideBounds;
        });

        // Map to Screen

        foreach (var triangle in triangles)
        {
            for (int vertexIndex = 0; vertexIndex < 3; ++vertexIndex)
            {
                // Vertex Shader
                triangle[vertexIndex] += Vector3.one;
                triangle[vertexIndex] *= 0.5f;
                triangle[vertexIndex].Scale(new Vector3(targetTexture.width, targetTexture.height, 1));
            }
        }

        // Rasterize
        // this follows the tutorial https://fgiesen.wordpress.com/2013/02/08/triangle-rasterization-in-practice/

        var pixels = targetTexture.GetPixels();
        foreach (var triangle in triangles)
        {
            int minX = Mathf.RoundToInt(Mathf.Clamp(Mathf.Min(triangle[0].x, triangle[1].x, triangle[2].x), 0, targetTexture.width));
            int maxX = Mathf.RoundToInt(Mathf.Clamp(Mathf.Max(triangle[0].x, triangle[1].x, triangle[2].x), 0, targetTexture.width));
            int minY = Mathf.RoundToInt(Mathf.Clamp(Mathf.Min(triangle[0].y, triangle[1].y, triangle[2].y), 0, targetTexture.height));
            int maxY = Mathf.RoundToInt(Mathf.Clamp(Mathf.Max(triangle[0].y, triangle[1].y, triangle[2].y), 0, targetTexture.height));

            for(int x = minX; x < maxX; ++x)
            {
                for(int y = minY; y < maxY; ++y)
                {
                    Vector2 p = new Vector2(x, y);
                    float w0 = CalculateBarycentric(triangle[0], triangle[1], p);
                    float w1 = CalculateBarycentric(triangle[0], triangle[1], p);
                    float w2 = CalculateBarycentric(triangle[0], triangle[1], p);

                    if(w0 >= 0 && w1 >= 0 && w2 >= 0)
                    {
                        // Fragment Shader
                        pixels[x+y*targetTexture.width] = Color.white;
                    }
                }
            }
        }

        // Output Merger Stage

        targetTexture.SetPixels(pixels);
    }

    // Calculates the Barycentric Weight of the Point to a given Edge
    // taken from https://fgiesen.wordpress.com/2013/02/08/triangle-rasterization-in-practice/
    float CalculateBarycentric(Vector2 a, Vector2 b, Vector2 p)
    {
        return (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x);
    }
}
