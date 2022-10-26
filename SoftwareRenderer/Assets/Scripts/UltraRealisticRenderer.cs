using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UltraRealisticRenderer : MonoBehaviour
{
    public Texture2D targetTexture;

    [ContextMenu("Render")]
    public void Render()
    {
        if (targetTexture == null)
        {
            targetTexture = new Texture2D(1920, 1080);
        }
        Render(Camera.main);
        targetTexture.Apply();
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
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
            var mvpMatrix = projectionMatrix * viewMatrix * meshFilter.transform.localToWorldMatrix;
            if (mesh == null)
                continue;
            Render(mesh, mvpMatrix);
        }
    }



    void Render(Mesh mesh, Matrix4x4 matrix)
    {
        // Render Stuff here

        // A triangle is An Array of 3 Vectors
        List<Vector3[/*3*/]> triangles = new List<Vector3[]>();

        // Input Assembler [✔]
        {
            Vector3[] vertices = mesh.vertices;
            int[] triangleIndices = mesh.triangles;

            for (int i = 0; i < triangleIndices.Length; i += 3)
            {
                Vector3[] triangle = new Vector3[3];
                triangle[0] = vertices[triangleIndices[i + 0]];
                triangle[1] = vertices[triangleIndices[i + 1]];
                triangle[2] = vertices[triangleIndices[i + 2]];
                triangles.Add(triangle);
            }
        }

        // Vertex Shader [✔]
        foreach (var triangle in triangles)
        {
            for(int i = 0; i < 3; i++)
            {
                // Shader Code
                triangle[i] = matrix.MultiplyPoint(triangle[i]);
            }
        }

        #region Turned Off
        // Hull Shader [TURNED OFF]
        // Tessellator [TURNED OFF]
        // Domain Shader [TURNED OFF]
        // Geometry Shader [TURNED OFF]
        #endregion

        // Rasterizer

        // Mapping the Normalized Device Coordinates (-1,1) to the Screen Size
        foreach (var triangle in triangles)
        {
            for (int i = 0; i < 3; i++)
            {
                // Map from [-1,1] to [0,1]
                triangle[i] += Vector3.one;
                triangle[i] *= 0.5f;

                triangle[i].Scale(new Vector3(targetTexture.width, targetTexture.height, 1));
            }
        }

        Color[] pixels = targetTexture.GetPixels();

        foreach (var triangle in triangles)
        {
            for(int x = 0; x < targetTexture.width; x++)
            {
                for(int y = 0; y < targetTexture.height; y++)
                {
                    // Check if pixel at x,y is in the triangle
                    Vector2 pointToCheck = new Vector2(x, y);
                    float w0 = CalculateBarycentric(triangle[0], triangle[1], pointToCheck);
                    float w1 = CalculateBarycentric(triangle[1], triangle[2], pointToCheck);
                    float w2 = CalculateBarycentric(triangle[2], triangle[0], pointToCheck);

                    // Are we inside the triangle
                    if (w0 >= 0 && w1 >= 0 && w2 >= 0)
                    {
                        // Fragment Shader

                        // set the pixel at x,y
                        pixels[x + y * targetTexture.width] = Color.magenta; // 📯
                    }
                }
            }
        }

        // Output Merger
        targetTexture.SetPixels(pixels);
        targetTexture.Apply();
    }


    // Calculates the Barycentric Weight of the Point to a given Edge
    // taken from https://fgiesen.wordpress.com/2013/02/08/triangle-rasterization-in-practice/
    float CalculateBarycentric(Vector2 a, Vector2 b, Vector2 p)
    {
        return (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x);
    }
}
