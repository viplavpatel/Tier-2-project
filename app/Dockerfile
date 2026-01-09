FROM nginx:alpine

# Copy custom HTML
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"] 
