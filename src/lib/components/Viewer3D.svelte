<script lang="ts">
	import { onMount } from 'svelte';

	interface Props {
		title?: string;
		description?: string;
		modelType?: 'cube' | 'sphere' | 'pyramid';
		color?: string;
		size?: number;
		autoRotate?: boolean;
	}

	let {
		title = '3D Görüntüleyici',
		description = '',
		modelType = 'cube',
		color = '#0f7c80',
		size = 2,
		autoRotate = true
	}: Props = $props();

	let container: HTMLDivElement | undefined;
	let rotation = $state({ x: 0, y: 0 });
	let isDragging = $state(false);
	let dragStart = { x: 0, y: 0 };

	onMount(() => {
		if (!container) return;

		// Create a canvas-based 3D representation
		const canvas = document.createElement('canvas');
		canvas.width = container.clientWidth;
		canvas.height = container.clientHeight;
		container.appendChild(canvas);

		const ctx = canvas.getContext('2d');
		if (!ctx) return;

		function drawCube() {
			const w = size;
			const h = size;
			const d = size;

			// Perspective transformation
			const scale = 50;
			const centerX = canvas.width / 2;
			const centerY = canvas.height / 2;

			// Define cube vertices
			const vertices = [
				[-w / 2, -h / 2, -d / 2],
				[w / 2, -h / 2, -d / 2],
				[w / 2, h / 2, -d / 2],
				[-w / 2, h / 2, -d / 2],
				[-w / 2, -h / 2, d / 2],
				[w / 2, -h / 2, d / 2],
				[w / 2, h / 2, d / 2],
				[-w / 2, h / 2, d / 2]
			];

			// Apply rotation
			const rotatedVertices = vertices.map((v) => {
				let [x, y, z] = v;

				// Rotate around X
				const cosX = Math.cos(rotation.x);
				const sinX = Math.sin(rotation.x);
				const y1 = y * cosX - z * sinX;
				const z1 = y * sinX + z * cosX;

				// Rotate around Y
				const cosY = Math.cos(rotation.y);
				const sinY = Math.sin(rotation.y);
				const x2 = x * cosY + z1 * sinY;
				const z2 = -x * sinY + z1 * cosY;

				return [x2, y1, z2];
			});

			// Project 3D to 2D
			const projectedVertices = rotatedVertices.map((v) => {
				const [x, y, z] = v;
				const perspective = 1 / (1 + z / 5);
				return [
					centerX + x * scale * perspective,
					centerY - y * scale * perspective
				];
			});

			// Clear canvas
			ctx.fillStyle = 'var(--color-bg-primary)';
			ctx.fillRect(0, 0, canvas.width, canvas.height);

			// Draw cube faces
			const faces = [
				[0, 1, 2, 3],
				[4, 5, 6, 7],
				[0, 1, 5, 4],
				[2, 3, 7, 6],
				[0, 3, 7, 4],
				[1, 2, 6, 5]
			];

			faces.forEach((face, idx) => {
				const points = face.map((i) => projectedVertices[i]);

				// Calculate depth for sorting
				const zSum = face.reduce((sum, i) => sum + rotatedVertices[i][2], 0);

				// Use different shades based on depth
				const brightness = Math.max(0.3, 0.5 + zSum / 30);
				const hexColor = color.substring(1);
				const r = parseInt(hexColor.substring(0, 2), 16);
				const g = parseInt(hexColor.substring(2, 4), 16);
				const b = parseInt(hexColor.substring(4, 6), 16);

				const br = Math.floor(r * brightness);
				const bg = Math.floor(g * brightness);
				const bb = Math.floor(b * brightness);
				const newColor = `rgb(${br},${bg},${bb})`;

				ctx.fillStyle = newColor;
				ctx.strokeStyle = color;
				ctx.lineWidth = 1;

				ctx.beginPath();
				ctx.moveTo(points[0][0], points[0][1]);
				for (let i = 1; i < points.length; i++) {
					ctx.lineTo(points[i][0], points[i][1]);
				}
				ctx.closePath();
				ctx.fill();
				ctx.stroke();
			});

			// Draw edges
			const edges = [
				[0, 1],
				[1, 2],
				[2, 3],
				[3, 0],
				[4, 5],
				[5, 6],
				[6, 7],
				[7, 4],
				[0, 4],
				[1, 5],
				[2, 6],
				[3, 7]
			];

			ctx.strokeStyle = color;
			ctx.lineWidth = 2;
			edges.forEach((edge) => {
				const [start, end] = edge;
				ctx.beginPath();
				ctx.moveTo(projectedVertices[start][0], projectedVertices[start][1]);
				ctx.lineTo(projectedVertices[end][0], projectedVertices[end][1]);
				ctx.stroke();
			});
		}

		function drawSphere() {
			const radius = size * 50;
			const centerX = canvas.width / 2;
			const centerY = canvas.height / 2;

			ctx.fillStyle = color;
			ctx.beginPath();
			ctx.arc(centerX, centerY, radius, 0, Math.PI * 2);
			ctx.fill();

			// Add shading
			const gradient = ctx.createRadialGradient(
				centerX - radius / 3,
				centerY - radius / 3,
				0,
				centerX,
				centerY,
				radius
			);
			gradient.addColorStop(0, color);
			gradient.addColorStop(1, '#000000');

			ctx.fillStyle = gradient;
			ctx.beginPath();
			ctx.arc(centerX, centerY, radius, 0, Math.PI * 2);
			ctx.fill();
		}

		function drawPyramid() {
			const w = size;
			const h = size * 1.5;
			const d = size;

			const scale = 50;
			const centerX = canvas.width / 2;
			const centerY = canvas.height / 2;

			// Pyramid vertices
			const vertices = [
				[0, -h / 2, 0], // Top
				[-w / 2, h / 2, -d / 2],
				[w / 2, h / 2, -d / 2],
				[w / 2, h / 2, d / 2],
				[-w / 2, h / 2, d / 2]
			];

			// Apply rotation
			const rotatedVertices = vertices.map((v) => {
				let [x, y, z] = v;

				const cosX = Math.cos(rotation.x);
				const sinX = Math.sin(rotation.x);
				const y1 = y * cosX - z * sinX;
				const z1 = y * sinX + z * cosX;

				const cosY = Math.cos(rotation.y);
				const sinY = Math.sin(rotation.y);
				const x2 = x * cosY + z1 * sinY;
				const z2 = -x * sinY + z1 * cosY;

				return [x2, y1, z2];
			});

			const projectedVertices = rotatedVertices.map((v) => {
				const [x, y, z] = v;
				const perspective = 1 / (1 + z / 5);
				return [
					centerX + x * scale * perspective,
					centerY - y * scale * perspective
				];
			});

			// Draw pyramid faces
			const faces = [
				[0, 1, 2],
				[0, 2, 3],
				[0, 3, 4],
				[0, 4, 1],
				[1, 2, 3, 4]
			];

			faces.forEach((face) => {
				const points = face.map((i) => projectedVertices[i]);

				const zSum = face.reduce((sum, i) => sum + rotatedVertices[i][2], 0);
				const brightness = Math.max(0.3, 0.5 + zSum / 30);

				const hexColor = color.substring(1);
				const r = parseInt(hexColor.substring(0, 2), 16);
				const g = parseInt(hexColor.substring(2, 4), 16);
				const b = parseInt(hexColor.substring(4, 6), 16);

				const br = Math.floor(r * brightness);
				const bg = Math.floor(g * brightness);
				const bb = Math.floor(b * brightness);

				ctx.fillStyle = `rgb(${br},${bg},${bb})`;
				ctx.strokeStyle = color;
				ctx.lineWidth = 1;

				ctx.beginPath();
				ctx.moveTo(points[0][0], points[0][1]);
				for (let i = 1; i < points.length; i++) {
					ctx.lineTo(points[i][0], points[i][1]);
				}
				ctx.closePath();
				ctx.fill();
				ctx.stroke();
			});
		}

		function animate() {
			if (autoRotate && !isDragging) {
				rotation.y += 0.005;
				rotation.x += 0.002;
			}

			// Clear and redraw
			ctx.clearRect(0, 0, canvas.width, canvas.height);

			// Draw background
			ctx.fillStyle = 'var(--color-bg-primary)';
			ctx.fillRect(0, 0, canvas.width, canvas.height);

			if (modelType === 'sphere') {
				drawSphere();
			} else if (modelType === 'pyramid') {
				drawPyramid();
			} else {
				drawCube();
			}

			requestAnimationFrame(animate);
		}

		animate();

		// Mouse events
		function handleMouseDown(e: MouseEvent) {
			isDragging = true;
			dragStart = { x: e.clientX, y: e.clientY };
		}

		function handleMouseMove(e: MouseEvent) {
			if (!isDragging) return;

			const deltaX = e.clientX - dragStart.x;
			const deltaY = e.clientY - dragStart.y;

			rotation.y += deltaX * 0.01;
			rotation.x += deltaY * 0.01;

			dragStart = { x: e.clientX, y: e.clientY };
		}

		function handleMouseUp() {
			isDragging = false;
		}

		canvas.addEventListener('mousedown', handleMouseDown);
		canvas.addEventListener('mousemove', handleMouseMove);
		canvas.addEventListener('mouseup', handleMouseUp);
		canvas.addEventListener('mouseleave', handleMouseUp);

		return () => {
			canvas.removeEventListener('mousedown', handleMouseDown);
			canvas.removeEventListener('mousemove', handleMouseMove);
			canvas.removeEventListener('mouseup', handleMouseUp);
			canvas.removeEventListener('mouseleave', handleMouseUp);
		};
	});
</script>

<div class="viewer-container">
	<div class="viewer-header">
		<h3>{title}</h3>
		{#if description}
			<p>{description}</p>
		{/if}
	</div>

	<div bind:this={container} class="canvas-container" />

	<div class="viewer-footer">
		<p class="controls-hint">💡 Döndürmek için sürükleyin</p>
	</div>
</div>

<style>
	.viewer-container {
		background: var(--color-bg-secondary);
		border: 1px solid var(--color-border);
		border-radius: var(--radius-lg);
		overflow: hidden;
		display: flex;
		flex-direction: column;
	}

	.viewer-header {
		padding: var(--spacing-4);
		border-bottom: 1px solid var(--color-border);
	}

	.viewer-header h3 {
		font-size: var(--text-base);
		font-weight: 700;
		color: var(--color-text-primary);
		margin-bottom: var(--spacing-1);
	}

	.viewer-header p {
		font-size: var(--text-sm);
		color: var(--color-text-secondary);
		margin: 0;
	}

	.canvas-container {
		flex: 1;
		min-height: 400px;
		cursor: grab;
		background: var(--color-bg-primary);
		position: relative;
	}

	.canvas-container:active {
		cursor: grabbing;
	}

	.viewer-footer {
		padding: var(--spacing-3);
		background: var(--color-bg-secondary);
		border-top: 1px solid var(--color-border);
		text-align: center;
	}

	.controls-hint {
		font-size: var(--text-xs);
		color: var(--color-text-secondary);
		margin: 0;
	}

	@media (max-width: 768px) {
		.canvas-container {
			min-height: 300px;
		}
	}
</style>
