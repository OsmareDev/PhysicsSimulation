import java.util.regex.*;
import java.util.TreeMap;

TreeMap<String, Integer[]> _vertexWithDistance = new TreeMap<String, Integer[]>();;

PBDSystem crea_model(
    float dens,
    float stiffness,
    float display_size,
    String model_name){

    String[] lines = loadStrings("models/" + model_name);
    int vertex_number = 0;
    float max_x = 0, min_x = 0;
    float max_y = 0, min_y = 0;
    float max_z = 0, min_z = 0;

    

    for (int i = 0 ; i < lines.length; i++) {
        if (lines[i].substring(0,2).equals("v ")){
            float[] nums = findDecimalNums(lines[i]);
            vertex_number++;

            if (max_x < nums[0]) max_x = nums[0];
            if (max_y < nums[1]) max_y = nums[1];
            if (max_z < nums[2]) max_z = nums[2];
            if (min_x > nums[0]) min_x = nums[0];
            if (min_y > nums[1]) min_y = nums[1];
            if (min_z > nums[2]) min_z = nums[2];
        } else {
            break;
        }
    }


    float masa = dens * (max_x-min_x)*(max_y-min_y)*(max_z-min_z);
    PBDSystem model = new PBDSystem(vertex_number,masa/vertex_number);

    for (int i = 0; i< vertex_number; i++){
        float[] nums = findDecimalNums(lines[i]);

        Particle p = model.particles.get(i);
        p.location.set(nums[0],nums[1],nums[2]);
        p.display_size = display_size;
    }

    for (int i = 0 ; i < lines.length; i++) {
        if (lines[i].equals("")) continue;
        if (lines[i].substring(0,2).equals("f ")){
            int[] nums = findIntegers(lines[i]);

            CreateDistanceRestrictions(nums, model);
            CreateShearRestrictions(nums, model);
            CreateBendRestrictions(model);
        }
    }
    
    return model;
}

void CreateDistanceRestrictions(int[] f, PBDSystem model) {
    /*
    Here the combinations for bending are taken advantage of and prepared while avoiding duplicating distance restrictions.
    */

    Particle p0 = model.particles.get(f[0]);
    Particle p1 = model.particles.get(f[1]);
    Particle p2 = model.particles.get(f[2]);

    // We check if the distance constraint has already been created
    if (!_vertexWithDistance.containsKey(f[0]+";"+f[1]) &&
        !_vertexWithDistance.containsKey(f[1]+";"+f[0])){
        // in case we do not save all the vertices belonging to the triangle
        Integer[] points = {f[1], f[0], f[2], -1};
        _vertexWithDistance.put(f[0]+";"+f[1], points);

        // we create the distance constraint
        Constraint c = new DistanceConstraint(p0, p1, PVector.dist(p0.location, p1.location), stiffness1);
        model.add_constraint(c);
    } else {
        // in case we need to add the missing point of the opposite triangle to the constraint
        Integer[] points = _vertexWithDistance.get(f[0]+";"+f[1]);
        if (points == null)
            points = _vertexWithDistance.get(f[1]+";"+f[0]);
        
        points[3] = f[2];
    }

    if (!_vertexWithDistance.containsKey(f[1]+";"+f[2]) &&
        !_vertexWithDistance.containsKey(f[2]+";"+f[1])){
        Integer[] points = {f[1], f[2], f[0], -1};
        _vertexWithDistance.put(f[1]+";"+f[2], points);

        Constraint c = new DistanceConstraint(p1, p2, PVector.dist(p1.location, p2.location), stiffness1);
        model.add_constraint(c);
    } else {
        Integer[] points = _vertexWithDistance.get(f[1]+";"+f[2]);
        if (points == null)
            points = _vertexWithDistance.get(f[2]+";"+f[1]);
        
        points[3] = f[0];
    }
    if (!_vertexWithDistance.containsKey(f[2]+";"+f[0]) &&
        !_vertexWithDistance.containsKey(f[0]+";"+f[2])){
        Integer[] points = {f[2], f[0], f[1], -1};
        _vertexWithDistance.put(f[2]+";"+f[0], points);

        Constraint c = new DistanceConstraint(p2, p0, PVector.dist(p2.location, p0.location), stiffness1);
        model.add_constraint(c);
    } else {
        Integer[] points = _vertexWithDistance.get(f[2]+";"+f[0]);
        if (points == null)
            points = _vertexWithDistance.get(f[0]+";"+f[2]);
        
        points[3] = f[1];
    }

    // vertex order with 4 vertices per face
    // https://stackoverflow.com/questions/23723993/converting-quadriladerals-in-an-obj-file-into-triangles
    if (f.length == 4){
        Particle p3 = model.particles.get(f[3]);

        if (!_vertexWithDistance.containsKey(f[2]+";"+f[3]) &&
            !_vertexWithDistance.containsKey(f[3]+";"+f[2])){
            Integer[] points = {f[3], f[2], f[0], -1};
            _vertexWithDistance.put(f[2]+";"+f[3], points);
            Constraint c = new DistanceConstraint(p2, p3, PVector.dist(p2.location, p3.location), stiffness1);
            model.add_constraint(c);
        } else {
            Integer[] points = _vertexWithDistance.get(f[2]+";"+f[3]);
            if (points == null)
                points = _vertexWithDistance.get(f[3]+";"+f[2]);
            
            points[3] = f[0];
        }
        if (!_vertexWithDistance.containsKey(f[3]+";"+f[0]) &&
            !_vertexWithDistance.containsKey(f[0]+";"+f[3])){
            Integer[] points = {f[3], f[0], f[2], -1};
            _vertexWithDistance.put(f[3]+";"+f[0], points);
            Constraint c = new DistanceConstraint(p3, p0, PVector.dist(p3.location, p0.location), stiffness1);
            model.add_constraint(c);
        } else {
            Integer[] points = _vertexWithDistance.get(f[3]+";"+f[0]);
            if (points == null)
                points = _vertexWithDistance.get(f[0]+";"+f[3]);
            
            points[3] = f[2];
        }
    }
}

void CreateShearRestrictions(int[] f, PBDSystem model) {
    Particle p0 = model.particles.get(f[0]);
    Particle p1 = model.particles.get(f[1]);
    Particle p2 = model.particles.get(f[2]);

    /*
        3-------2
        |      /|
        |    /  |
        |  /    |
        |/      |
        0-------1
    */

    Constraint c = new ShearConstraint(p1, p0, p2, stiffness2);
    model.add_constraint(c);

    if (f.length == 4){
        Particle p3 = model.particles.get(f[3]);

        c = new ShearConstraint(p3, p2, p0, stiffness2);
        model.add_constraint(c);

        // solo porque son quads
        c = new ShearConstraint(p0, p3, p1, stiffness2);
        model.add_constraint(c);
        c = new ShearConstraint(p2, p1, p3, stiffness2);
        model.add_constraint(c);
    }
}

void CreateBendRestrictions(PBDSystem model) {
    for (Integer[] points : _vertexWithDistance.values()) 
    {
        if (points[0] > 0 && points[1] > 0 && points[2] > 0 && points[3] > 0) {
            Particle p0 = model.particles.get(points[0]);
            Particle p1 = model.particles.get(points[1]);
            Particle p2 = model.particles.get(points[2]);
            Particle p3 = model.particles.get(points[3]);

            Constraint c = new BendConstraint(p0, p1, p2, p3, stiffness3);
            model.add_constraint(c);
        }
    }
}

float[] findDecimalNums(String stringToSearch) {
    Pattern decimalNumPattern = Pattern.compile("-?\\d+(\\.\\d+)?");
    Matcher matcher = decimalNumPattern.matcher(stringToSearch);

    float[] decimalNumList = {0.0, 0.0, 0.0};
    int id = 0;
    while (matcher.find()) {
        decimalNumList[id] = parseFloat(matcher.group());
        id++;
    }

    return decimalNumList;
}

int[] findIntegers(String stringToSearch) {
    Pattern integerPattern = Pattern.compile("-?\\d+");
    Matcher matcher = integerPattern.matcher(stringToSearch);

    int id = 0;
    int cont = 0;
    while (matcher.find()) {
        if (cont > 0) {
            cont++;
            if (cont > 2) cont = 0;
            continue;
        }
        cont++;

        //println(matcher.group());
        id++;
    }

    int[] integerList = new int[id];
    matcher = integerPattern.matcher(stringToSearch);
    
    id = 0;
    cont = 0;
    while (matcher.find()) {
        if (cont > 0) {
            cont++;
            if (cont > 2) cont = 0;
            continue;
        }
        cont++;

        // 1 is subtracted since the indices in obj do not start at 0
        integerList[id] = Integer.parseInt(matcher.group()) - 1;
        id++;
    }
    
    return integerList;
}