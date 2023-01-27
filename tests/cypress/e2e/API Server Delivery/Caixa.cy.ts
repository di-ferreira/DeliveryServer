describe('Rotas caixa', () => {
    let id:number;

    it('Criar caixa - 01', () => {
        cy.request({
            method: 'POST',
            url: '/caixas'
        }).then((Response) => {
            let hoje = new Date(Date.now());

            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('Caixa aberto com sucesso!');
            expect(Response.body[1].total).to.equal(0.00);
            expect(new Date(Response.body[1].dataAbertura).getDate()+1).to.equal(hoje.getDate());
            id = Response.body[1].id;
        });
    });
    
    it('Criar caixa com caixa já aberto', () => {        
        cy.request({
            method: 'POST',
            url: '/caixas',
            failOnStatusCode: false
        }).then((Response) => {
            expect(Response.status).to.equal(400);
            expect(Response.body.message).to.equal('Caixa já está aberto!');
        });
    });

    it('Buscar caixas', () => {
        cy.request('/caixas')
            .then((Response) => {
                expect(Response.status).to.equal(200);
                expect(Response.body.length).to.gte(1);
            });
    });

    it('Buscar caixas por data', () => {
        cy.request('/caixas?dataCaixa=25-01-2023')
            .then((Response) => {
                expect(Response.status).to.equal(200);
                expect(Response.body.count).to.gte(1);
                expect(Response.body.data).to.equal('25-01-2023');
            });
    });

    it('Buscar caixas entre data', () => {
        cy.request('/caixas?dataInicial=5-01-2023&dataFinal=27-01-2023')
            .then((Response) => {
                expect(Response.status).to.equal(200);
                expect(Response.body.count).to.gte(1);
                expect(Response.body[0].data).to.contain('01-2023');
            });
    });

    it('Buscar caixa por ID', () => {
        cy.request(`/caixas/${id}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(id);
        });
    });

    it('Fechar caixa', () => {
        cy.request({
            method: 'PUT',
            url: `/caixas/fechar/${id}`
        }).then(Response => {
        console.log(Response.body)
            expect(Response.status).to.equal(200);
            expect(Response.body[1].id).to.equal(id);
            expect(Response.body[1].aberto).to.equal(false);
        });
    });

});